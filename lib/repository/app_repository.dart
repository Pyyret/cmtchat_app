import 'dart:async';

import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/data/local_db_api.dart';
import 'package:cmtchat_app/services/local/local_cache_service.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';



class AppRepository{
  /// Constructor
  AppRepository({
    required ILocalCacheService localCache,
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,
  })
      : _localCache = localCache,
        _localDb = dataService,
        _webUserService = webUserService
  {
    _tryLoginFromCache();
  }

  /// DataProvider APIs ///
  // Local
  final ILocalCacheService _localCache;
  final LocalDbApi _localDb;

  // WebDependant
  final WebUserServiceApi _webUserService;



  /// Private variables ///
  final _loggedInStreamController = StreamController<bool>.broadcast();

  bool _loggedIn = false;
  User _user = User();



  /// Getters ///
  User get user => _user;
  Stream<bool> get loggedIn async* {
    yield _loggedIn;
    yield* _loggedInStreamController.stream;
  }

  WebUserServiceApi get webUserService => _webUserService;



  Future<void> logOut() async {
    await _webUserService.disconnect(WebUser.fromUser(_user));
    await _localCache.clear();
    await _localDb.cleanDb();
    _user = User();
    _loggedIn = false;

    _loggedInStreamController.add(_loggedIn);
  }

  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<void> newUserLogin(String username) async {

    WebUser webUser = WebUser(
        username: username,
        lastSeen: DateTime.now(),
        active: true);

    WebUser connectedWebUser = await _webUserService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);

    User savedUser = await _cacheAndSave(connectedUser);
    _initializeRepo(savedUser);
  }


  Future<void> _tryLoginFromCache() async {

    // Check local cache for a previously logged in user
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
      await _cacheAndSave(cachedUser);

      _initializeRepo(cachedUser);
    }
  }


  // Saves connected user to localDb & cache
  Future<User> _cacheAndSave(User connectedUser) async {
    await _localDb.saveUser(connectedUser);
    await _localCache.save('USER_ID', {'user_id': connectedUser.id.toString()});
    return connectedUser;
  }


  Future<void> _initializeRepo(User connectedUser) async {
    _user = connectedUser;
    _loggedIn = true;
    _loggedInStreamController.add(_loggedIn);
  }

}