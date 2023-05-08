import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';

class UserViewModel {
  final IWebUserService _webUserService;
  final IDataService _dataService;
  final ILocalCacheService _localCacheService;

  late User _user;

  UserViewModel(this._webUserService, this._dataService, this._localCacheService);

  User get user => _user;

  Future<User?> checkForCachedUser() async {
    // Check local cache for a previously logged in user
    final cachedUserId = _localCacheService.fetch('USER_ID');

    // If cachedUserId is not empty,
    // check localDb for user with the cashed user id, otherwise return null
    return cachedUserId.isNotEmpty
        ? await _dataService.findUser(int.parse(cachedUserId['user_id']))
        : null;
  }


  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<User> connectNewUser(String userName) async {
    final webUser = WebUser(
        username: userName,
        lastSeen: DateTime.now(),
        active: true
    );

    WebUser connectedWebUser = await _webUserService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);

    return connectedUser;
  }

  Future<User> connect(User localUser) async {
    // Create a WebUser from the cachedUser and update relevant variables
      final webUser = WebUser.fromUser(localUser)
        ..lastSeen = DateTime.now()
        ..active = true;

      // Connect to webserver, then update the local cachedUser
      WebUser connectedWebUser = await _webUserService.connect(webUser);
      localUser.update(connectedWebUser);

      return localUser;
    }

  // Saves connected user to localDb & cache
  Future<User> cacheAndSave(User connectedUser) async {
    await _dataService.saveUser(connectedUser);
    await _localCacheService.save('USER_ID', {'user_id': connectedUser.id.toString()});
    _user = connectedUser;
    return connectedUser;
  }
}