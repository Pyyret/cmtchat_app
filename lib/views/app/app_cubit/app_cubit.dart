import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


abstract class AppState extends Equatable {
  final User? user;
  const AppState({this.user});
  @override
  List<Object?> get props => [user];
}
class AppInitial extends AppState {}
class NoUserConnect extends AppState {}
class Loading extends AppState {}
class UserConnectSuccess extends AppState {
  const UserConnectSuccess({required User user}) : super(user: user);
}


class AppCubit extends Cubit<AppState> {
  final IWebUserService _webUserService;
  final IDataService _dataService;
  final ILocalCacheService _localCacheService;

  AppCubit(this._webUserService, this._dataService, this._localCacheService)
      : super(AppInitial());



  Future<void> loginFromCache() async {
    emit(Loading());
    // Check local cache for a previously logged in user
    final cachedUserId = _localCacheService.fetch('USER_ID');

    // If cachedUserId is not empty,
    // check localDb for user with the cashed user id.
    User? cachedUser;
    if(cachedUserId.isNotEmpty) {
      cachedUser = await _dataService.findUser(int.parse(cachedUserId['user_id']));
    }

    // If found in localDb => connect & save user, then emit UserConnectSuccess
    if(cachedUser != null) {
      User connectedUser = await _connect(cachedUser);
      final User savedUser = await _cacheAndSave(connectedUser);
      emit(UserConnectSuccess(user: savedUser));
    }
    else { emit(NoUserConnect()); }
  }

  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<void> newUserLogin(String username) async {
    emit(Loading());
    User connectedUser = await _connectNewUser(username);
    final User savedUser = await _cacheAndSave(connectedUser);
    emit(UserConnectSuccess(user: savedUser));
  }


  Future<User> _connectNewUser(String userName) async {
    final webUser = WebUser(
        username: userName,
        lastSeen: DateTime.now(),
        active: true
    );

    WebUser connectedWebUser = await _webUserService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);
    return connectedUser;
  }

  Future<User> _connect(User localUser) async {
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
  Future<User> _cacheAndSave(User connectedUser) async {
    await _dataService.saveUser(connectedUser);
    await _localCacheService.save('USER_ID', {'user_id': connectedUser.id.toString()});
    return connectedUser;
  }

}