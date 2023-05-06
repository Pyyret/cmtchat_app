import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/collections/localservice_collection.dart';

import 'package:cmtchat_app/views/app/app_cubit/app_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';





class AppCubit extends Cubit<AppState> {
  final IWebUserService _userService;
  final IDataService _dataService;
  final ILocalCacheService _localCacheService;

  AppCubit(this._userService, this._dataService, this._localCacheService)
      : super(AppInitial());


  Future<void> checkCache() async {
    emit(Loading());
    // Check local cache for a previously logged in user
    final cachedUserId = _localCacheService.fetch('USER_ID');
    User? cachedUser;

    // Check localDb for user with the cashed user id
    if(cachedUserId.isNotEmpty) {
      cachedUser = await _dataService
          .findUser(int.parse(cachedUserId['user_id']));
    }

    // If found in the localDb => Connect to webserver and update
    if(cachedUser != null) {
      final cachedWebUser = WebUser.fromUser(cachedUser)
        ..lastSeen = DateTime.now()
        ..active = true;
      WebUser connectedWebUser = await _userService.connect(cachedWebUser);
      cachedUser.update(connectedWebUser);

      // Then save in cache and update state
      return _saveAndEmit(cachedUser);
    }

    // Otherwise emit NoUser state for OnboardingUi to build
    emit(NoUserConnect());
  }


  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<void> create(String userName) async {
    emit(Loading());
    final webUser = WebUser(
        username: userName,
        lastSeen: DateTime.now(),
        active: true
    );

    WebUser connectedWebUser = await _userService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);

    return _saveAndEmit(connectedUser);
  }

  // Saves connected user to localDb, cache, and emits UserConnectSuccess state
  Future<void> _saveAndEmit(User connectedUser) async {
    await _dataService.saveUser(connectedUser);
    await _localCacheService.save('USER_ID', {'user_id': connectedUser.id.toString()});
    emit(UserConnectSuccess(connectedUser));
  }
}