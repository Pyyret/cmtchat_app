import 'dart:async';

import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/local_db_api.dart';
import 'package:cmtchat_app/services/local/local_cache_service.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_api.dart';
import 'package:cmtchat_app/services/web/receipt/receipt_service_api.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';

/// App repository ///
class Repository{

  /// DataProviders
  // Local
  final LocalCacheApi _localCache;
  final LocalDbApi _localDb;
  // WebDependant
  final WebUserServiceApi _webUserService;
  final WebMessageServiceApi _webMessageService;
  final ReceiptServiceApi _receiptService;

  /// Private variables
  User _user = User.noUser();
  StreamSubscription<WebMessage>? _webMessageSub;
  StreamSubscription<Receipt>? _receiptSub;
  final List<Receipt> _savedReceipts = List<Receipt>.empty(growable: true);

  /// Constructor
  Repository({
    required LocalCacheApi localCache,
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,
    required WebMessageServiceApi webMessageService,
    required ReceiptServiceApi receiptService })
      : _localCache = localCache,
        _localDb = dataService,
        _webUserService = webUserService,
        _webMessageService = webMessageService,
        _receiptService = receiptService;



  test() { _webUserService.disconnect(WebUser.fromUser(user: _user)); }


  /// Getters
  User get user => _user;
  String get userWebId => _user.webId;
  WebUserServiceApi get webUserService => _webUserService;


  /// Streams
  Stream<List<Chat>> allChatsUpdatedStream() async* {
    yield* await _localDb.allChatsStream();
  }
  Stream<List<Message>> chatMessageStream({required int chatId}) async* {
    yield* await _localDb.chatMessageStream(chatId);
  }

  /// Methods
  Future<void> updateReadMessages({required List<Message> msgList}) async {
    for(Message msg in msgList) {
      final receipt = Receipt.read(message: msg);
      msg.updateReceipt(receipt: receipt);
      _receiptService.send(receipt);
    }
    await _localDb.updateMessages(msgList: msgList);
  }

  Future<void> sendMessage({required Chat chat, required WebMessage message}) async {
    final sentMsg = Message.fromWeb(
        message: await _webMessageService.send(message: message)
    )..status = ReceiptStatus.sent;
    await _localDb.saveSentMessage(chat: chat, message: sentMsg);
    final receipts = _savedReceipts
        .where((receipt) => receipt.messageId == sentMsg.webId)
        .toList();
    if(receipts.isNotEmpty) {
      _savedReceipts.removeWhere((r) => r.messageId == sentMsg.webId);
      _updateMessageReceipt(receipt: receipts.last, message: sentMsg);
    }
  }

  Future<Chat> getChat(WebUser webUser) async {
    return await _localDb.findChatWithWebId(userWebId: webUser.id!)
        ?? await _localDb.saveNewChat(
            owner: _user,
            receiver: User.fromWebUser(webUser: webUser)
        );
  }

  // Creates a new User from username entered in the OnboardingUi, connects
  // and saves it, returns the new user
  Future<User> newUserLogin(String username) async {
    WebUser webUser = WebUser(username: username)..active = true;
    _user = User.fromWebUser(webUser: await _webUserService.connect(webUser));
    return _cacheAndSave(_user);
  }

  // Check local cache for a previously logged in user and fetch it from
  // the local db. If found, update relevant variables and cache, connect
  // to webserver and return the user.
  Future<User?> tryLoginFromCache() async {
    final cachedUserId = _localCache.fetch('USER_ID');
    if(cachedUserId.isNotEmpty) {
      User? cachedUser = await _localDb
          .getUser(userId: int.parse(cachedUserId['user_id']));
      if(cachedUser != null) {
        final webUser = WebUser.fromUser(user: cachedUser)
          ..lastSeen = DateTime.now()
          ..active = true;
        cachedUser.update(await _webUserService.connect(webUser));
        print('User from cache: ${cachedUser.username}');
        return await _cacheAndSave(cachedUser);
      }
    }
    return null;
  }

  Future<void> logOut() async {
    print('User logged out: ${_user.webId}');
    await _webUserService.disconnect(WebUser.fromUser(user: _user));
    await _localCache.clear();
    await _localDb.cleanDb();
    _user = User.noUser();
  }

  /// Private Methods ///
  void _initializeRepository({required User user}) {
    _user = user;
    _subscribeToWebMessages();
    _subscribeToReceipts();
  }

  // Saves connected user to localDb & cache
  Future<User> _cacheAndSave(User connectedUser) async {
    final savedUser = await _localDb.putUser(user: connectedUser);
    await _localCache.save('USER_ID', {'user_id': savedUser.id.toString()});
    _initializeRepository(user: savedUser);
    return savedUser;
  }

  Future<void> _subscribeToWebMessages() async {
    await _webMessageSub?.cancel();
    await _webMessageService.cancelChangeFeed();
    _webMessageSub = _webMessageService
        .messageStream(webUserId: _user.webId)
        .listen((message) async {
          final newMessage = Message.fromWeb(message: message);
          Chat? chat = await _localDb.findChatWithWebId(userWebId: message.from);
          if(chat != null) {
            _localDb.saveReceivedMessage(chat: chat, message: newMessage);}
          else {
            final receiver = await _webUserService
                .fetch([message.from])
                .then((list) => list.single)
                .then((webUser) => User.fromWebUser(webUser: webUser)
            );
            _localDb.saveNewChat(
                owner: _user,
                receiver: receiver,
                message: newMessage);
          }
          _receiptService.send(Receipt.delivered(message: message));
        });
  }

  Future<void> _subscribeToReceipts() async {
    await _receiptSub?.cancel();
    await _receiptService.cancelChangeFeed();
    _receiptSub = _receiptService
        .receiptStream(activeUser: WebUser.fromUser(user: _user))
        .listen((receipt) async {
          final message = await _localDb
              .findMessageWith(webId: receipt.messageId);
          if (message != null) {
            _updateMessageReceipt(receipt: receipt, message: message);
          }
          else { _savedReceipts.add(receipt); }
        });
  }

  Future<void> _updateMessageReceipt({
    required Receipt receipt, required Message message
  }) async{
    message.status = receipt.status;
    message.receiptTimestamp = receipt.timestamp;
    await _localDb.updateMessages(msgList: [message]);
  }
}