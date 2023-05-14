import 'dart:async';

import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/data/local_db_api.dart';
import 'package:cmtchat_app/services/local/local_cache_service.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';

/// App repository ///
class AppRepository{

  /// Constructor
  AppRepository({
    required ILocalCacheService localCache,
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,
  })
      : _localCache = localCache,
        _localDb = dataService,
        _webUserService = webUserService;

  /// DataProvider APIs ///
  // Local
  final ILocalCacheService _localCache;
  final LocalDbApi _localDb;

  // WebDependant
  final WebUserServiceApi _webUserService;


  /// Private variables ///
  User _user = User.noUser();




  testChat() {
    Chat test = Chat()..owners.add(_user);
    _localDb.saveChat(test, _user.id);
  }


  test() { _webUserService.disconnect(WebUser.fromUser(_user)); }


  /// Getters ///
  User get user => _user;
  String? get userWebId => _user.webUserId;

  WebUserServiceApi get webUserService => _webUserService;


  /// Methods ///

  Future<Chat> getChat(WebUser webUser) async {
    Chat? chat = await _localDb.findChatWith(webUser.webUserId!);
    if(chat == null) {
      final User newUser = User.fromWebUser(webUser: webUser);
      final newChat = Chat()
        ..owners.add(_user)
        ..owners.add(newUser);
      chat = await _localDb.saveChat(newChat, _user.id);
    }
    return chat;
  }

  Future<Stream<List<Chat>>> allChatsUpdatedStream() async =>
      await _localDb.allChatsUpdatedStream(_user.id);

  Future<Stream<List<Message>>> chatMessageStream({required int chatId}) async =>
      await _localDb.chatMessageStream(chatId);

  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<User?> newUserLogin(String username) async {
    WebUser webUser = WebUser(
        username: username,
        lastSeen: DateTime.now(),
        active: true);

    WebUser connectedWebUser = await _webUserService.connect(webUser);
    _user = User.fromWebUser(webUser: connectedWebUser);
    await _cacheAndSave(_user);
    return _user;
  }

  // Check local cache for a previously logged in user
  Future<User?> tryLoginFromCache() async {
    final cachedUserId = _localCache.fetch('USER_ID');

    // If cachedUserId is not empty,
    // check localDb for user with the cashed user id.
    User? cachedUser;
    if(cachedUserId.isNotEmpty) {

      cachedUser = await _localDb.getUser(int.parse(cachedUserId['user_id']));
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
      print('savedUser');
      print(savedUser);
      return savedUser;
    }
    return null;
  }


  // Saves connected user to localDb & cache
  Future<User?> _cacheAndSave(User connectedUser) async {
    int userId = await _localDb.saveUser(connectedUser);
    _user = await _localDb.getUser(userId) ?? User.noUser();
    await _localCache.save('USER_ID', {'user_id': _user.id.toString()});
    return _user;
  }

  Future<void> logOut() async {
    print(_user.webUserId);
    if(_user != null)  {
      await _webUserService.disconnect(WebUser.fromUser(_user));
    }
    await _localCache.clear();
    await _localDb.cleanDb();
    _user = User.noUser();
  }
}