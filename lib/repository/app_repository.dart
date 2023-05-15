import 'dart:async';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/data/local_db_api.dart';
import 'package:cmtchat_app/services/local/local_cache_service.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';

/// App repository ///
class AppRepository{

  /// DataProviders
  // Local
  final ILocalCacheService _localCache;
  final LocalDbApi _localDb;
  // WebDependant
  final WebUserServiceApi _webUserService;
  final WebMessageServiceApi _webMessageService;
  final ReceiptServiceApi _receiptService;

  /// Private variables
  User _user = User.noUser();
  StreamSubscription<WebMessage>? _webMessageSub;
  StreamSubscription<Receipt>? _receiptSub;
  final List<Receipt> _unhandledReceipts = List<Receipt>.empty(growable: true);

  /// Constructor
  AppRepository({
    required ILocalCacheService localCache,
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,
    required WebMessageServiceApi webMessageService,
    required ReceiptServiceApi receiptService,
  })
      : _localCache = localCache,
        _localDb = dataService,
        _webUserService = webUserService,
        _webMessageService = webMessageService,
        _receiptService = receiptService;



  test() { _webUserService.disconnect(WebUser.fromUser(_user)); }


  /// Getters ///
  User get user => _user;
  String? get userWebId => _user.webUserId;
  WebUserServiceApi get webUserService => _webUserService;


  /// Methods ///

  Future<void> updateReadMessages({required List<Message> msgList}) async {
    for(Message msg in msgList) {
      msg.status = ReceiptStatus.read;
      msg.receiptTimestamp = DateTime.now();
      final receipt = Receipt(
          recipient: msg.from.value!.webUserId!,
          messageId: msg.webId!,
          status: ReceiptStatus.read,
          timestamp: DateTime.now());
      _receiptService.send(receipt);
    }
    await _localDb.updateMessages(msgList: msgList);
  }

  Future<void> sendMessage({required Chat chat, required WebMessage message})
  async {
    final sentWebMessage = await _webMessageService.send(message: message);
    final sentMessage = Message.fromWebMessage(message: sentWebMessage)
      ..status = ReceiptStatus.sent;
    await _localDb.saveSentMessage(chat: chat, message: sentMessage);
    final receipts = _unhandledReceipts
        .where((receipt) => receipt.messageId == sentMessage.webId)
        .toList();
    if(receipts.isNotEmpty) {
      _unhandledReceipts
          .removeWhere((receipt) => receipt.messageId == sentMessage.webId);
      _updateMessageReceipt(receipt: receipts.last, message: sentMessage);
    }
  }

  Future<Chat> getChat(WebUser webUser) async {
    Chat? chat = await _localDb.findChatWithWebUser(webUserId: webUser.webUserId!);
    chat ??= await _localDb.saveNewChat(
        chat: Chat(),
        owner: _user,
        receiver: User.fromWebUser(webUser: webUser));
    return chat;
  }

  Future<Stream<List<Chat>>> allChatsUpdatedStream() =>
      _localDb.allChatsStream();

  Future<Stream<List<Message>>> chatMessageStream({required int chatId}) =>
      _localDb.chatMessageStream(chatId);


  Future<User?> newUserLogin(String username) async {
    // Creates a new User, connects and saves it, from username entered
    // in the OnboardingUi.
    WebUser webUser = WebUser(
        username: username,
        lastSeen: DateTime.now(),
        active: true );
    WebUser connectedWebUser = await _webUserService.connect(webUser);
    _user = User.fromWebUser(webUser: connectedWebUser);
    await _cacheAndSave(_user);
    print('New user logged in $_user');
    return _user;
  }

  Future<User?> tryLoginFromCache() async {
    // Check local cache for a previously logged in user
    final cachedUserId = _localCache.fetch('USER_ID');
    // If cachedUserId is not empty,
    // check localDb for user with the cashed user id.
    User? cachedUser;
    if(cachedUserId.isNotEmpty) {
      cachedUser = await _localDb
          .getUser(userId: int.parse(cachedUserId['user_id']));
    }
    // If found in localDb => connect & save user, then emit UserConnectSuccess
    if(cachedUser != null) {
      // Create a WebUser from the cachedUser and update relevant variables
      final webUser = WebUser.fromUser(cachedUser)
        ..lastSeen = DateTime.now()
        ..active = true;
      // Connect to webserver, then update the local cache
      WebUser connectedWebUser = await _webUserService.connect(webUser);
      cachedUser.update(connectedWebUser);
      final savedUser = await _cacheAndSave(cachedUser);
      print('User from cache: $savedUser');
      return savedUser;
    }
    return null;
  }

  Future<void> logOut() async {
    print('User logged out: ${_user.webUserId}');
    await _webUserService.disconnect(WebUser.fromUser(_user));
    await _localCache.clear();
    await _localDb.cleanDb();
    _user = User.noUser();
  }


  /// Private Methods ///

  _initializeRepository({required User savedAndConnectedUser}) {
    _user = savedAndConnectedUser;
    _subscribeToWebMessages();
    _subscribeToReceipts();
  }

  // Saves connected user to localDb & cache
  Future<User> _cacheAndSave(User connectedUser) async {
    final savedUser = await _localDb.putUser(user: connectedUser);
    await _localCache.save('USER_ID', {'user_id': savedUser.id.toString()});
    _initializeRepository(savedAndConnectedUser: savedUser);
    return savedUser;
  }

  _subscribeToWebMessages() async {
    await _webMessageSub?.cancel();
    await _webMessageService.cancelChangeFeed();
    _webMessageSub = _webMessageService
        .messageStream(activeUser: WebUser.fromUser(_user))
        .listen((message) async {
          final newMessage = Message.fromWebMessage(message: message);
          Chat? chat = await _localDb.findChatWithWebUser(webUserId: message.from);
          if(chat != null) {
            _localDb.saveReceivedMessage(chat: chat, message: newMessage); }
          else {
            final receiver = await _webUserService
                .fetch([message.from])
                .then((list) => list.single)
                .then((webUser) => User.fromWebUser(webUser: webUser) );
            _localDb.saveNewChat(
                chat: Chat(),
                owner: _user,
                receiver: receiver,
                message: newMessage );
          }
          final receipt = Receipt(
              recipient: message.from,
              messageId: message.webId,
              status: ReceiptStatus.delivered,
              timestamp: DateTime.now() );
          _receiptService.send(receipt);
        });
  }

  _subscribeToReceipts() async {
    await _receiptSub?.cancel();
    await _receiptService.cancelChangeFeed();
    _receiptSub = _receiptService
        .receiptStream(activeUser: WebUser.fromUser(_user))
        .listen((receipt) async {
          final message = await _localDb.findMessageWith(webId: receipt.messageId);
          if (message != null) {
            _updateMessageReceipt(receipt: receipt, message: message); }
          else { _unhandledReceipts.add(receipt); }
        });
  }

  _updateMessageReceipt({required Receipt receipt, required Message message})
  async{
    message.status = receipt.status;
    message.receiptTimestamp = receipt.timestamp;
    await _localDb.updateMessages(msgList: [message]);
  }
}