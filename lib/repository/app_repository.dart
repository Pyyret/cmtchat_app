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
    _activeUsersStreamStart();
  }

  /// DataProvider APIs ///
  // Local
  final ILocalCacheService _localCache;
  final LocalDbApi _localDb;


  // WebDependant
  final WebUserServiceApi _webUserService;


  /// Private variables ///
  User? _user;


  StreamSubscription<List<WebUser>>? _activeUsersSub;

  _activeUsersStreamStart()  {
    _activeUsersSub = _webUserService
        .activeUsersStream()
        .listen((list) async {
          print(list);
          print('faaaan');
    });
  }
  updatedList(list) {

  }


  /// Getters ///
  test() { _webUserService.disconnect(WebUser.fromUser(_user!)); }

  String? get userWebId => _user?.webUserId;
  WebUserServiceApi get webUserService => _webUserService;

  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<User?> newUserLogin(String username) async {
    WebUser webUser = WebUser(
        username: username,
        lastSeen: DateTime.now(),
        active: true);

    WebUser connectedWebUser = await _webUserService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);

    await _cacheAndSave(connectedUser);
    print(_user);
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
    _user = await _localDb.getUser(userId);
    await _localCache.save('USER_ID', {'user_id': _user?.id.toString()});
    return _user;
  }

  Future<void> logOut() async {
    print(_user?.webUserId);
    if(_user != null)  {
      await _webUserService.disconnect(WebUser.fromUser(_user!));
    }
    await _localCache.clear();
    await _localDb.cleanDb();
    return _user = null;
  }

}