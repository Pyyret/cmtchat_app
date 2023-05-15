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

  /// Private variables
  User _user = User.noUser();
  StreamSubscription<WebMessage>? _webMessageSub;

  /// Constructor
  AppRepository({
    required ILocalCacheService localCache,
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,
    required WebMessageServiceApi webMessageService,
  })
      : _localCache = localCache,
        _localDb = dataService,
        _webUserService = webUserService,
        _webMessageService = webMessageService;



  test() { _webUserService.disconnect(WebUser.fromUser(_user)); }


  /// Getters ///
  User get user => _user;
  String? get userWebId => _user.webUserId;
  WebUserServiceApi get webUserService => _webUserService;


  /// Methods ///

  Future<void> sendMessage({required Chat chat, required String contents}) async {
    final webMessage = WebMessage(
        to: chat.receiver.value!.webUserId!,
        from: _user.webUserId!,
        timestamp: DateTime.now(),
        contents: contents
    );
    final sentWebMessage = await _webMessageService.send(message: webMessage);
    final sentMessage = Message.fromWebMessage(message: sentWebMessage);
    _localDb.saveSentMessage(chat: chat, message: sentMessage);
  }

  Future<Chat> getChat(WebUser webUser) async {
    Chat? chat = await _localDb.findChatWithWebUser(webUserId: webUser.webUserId!);
    chat ??= await _localDb.saveNewChat(
        chat: Chat(),
        owner: _user,
        receiver: User.fromWebUser(webUser: webUser));
    return chat;
    }

  Future<Stream<List<Chat>>> allChatsUpdatedStream() async =>
      await _localDb.allChatsStream();

  Future<Stream<List<Message>>> chatMessageStream({required int chatId}) async =>
      await _localDb.chatMessageStream(chatId);


  Future<User?> newUserLogin(String username) async {
    // Creates a new User, connects and saves it, from username entered
    // in the OnboardingUi.
    WebUser webUser = WebUser(
        username: username,
        lastSeen: DateTime.now(),
        active: true);

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

  // Saves connected user to localDb & cache
  Future<User> _cacheAndSave(User connectedUser) async {
    final savedUser = await _localDb.putUser(user: connectedUser);
    await _localCache.save('USER_ID', {'user_id': savedUser.id.toString()});
    _initializeRepository(savedAndConnectedUser: savedUser);
    return savedUser;
  }

  _initializeRepository({required User savedAndConnectedUser}) {
    _user = savedAndConnectedUser;
    _subscribeToWebMessages();
  }

  _subscribeToWebMessages() async {
    await _webMessageSub?.cancel();
    await _webMessageService.cancelChangeFeed();
    _webMessageSub = _webMessageService
        .messageStream(activeUser: WebUser.fromUser(_user))
        .listen((message) async {
      print('message received: $message');
      final newMessage = Message.fromWebMessage(message: message);
      Chat? chat = await _localDb.findChatWithWebUser(webUserId: message.from);
      if(chat != null) {
        _localDb.saveReceivedMessage(chat: chat, message: newMessage);
      }
      else {
        final receiver = await _webUserService
            .fetch([message.from])
            .then((list) => list.single)
            .then((webUser) => User.fromWebUser(webUser: webUser)
        );
        _localDb.saveNewChat(
            chat: Chat(),
            owner: _user,
            receiver: receiver,
            message: newMessage
        );
      }
    });
  }
}