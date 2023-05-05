import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/cache/local_cache.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:cmtchat_app/states_management/user_cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final IWebUserService _userService;
  final IDataService _dataService;
  final ILocalCache _localCache;

  UserCubit(this._userService, this._dataService, this._localCache)
      : super(UserInitial()) { checkCache(); }


  Future<void> checkCache() async {
    emit(Loading());
    // Check local cache for a previously logged in user
    final cachedUserId = _localCache.fetch('USER_ID');
    User? cachedUser = await _dataService
        .findUser(int.parse(cachedUserId['user_id']));

    // If found in the localDb => Connect to webserver and update
    if(cachedUserId.isNotEmpty && cachedUser != null) {
      final cachedWebUser = WebUser.fromUser(cachedUser)
        ..lastSeen = DateTime.now()
        ..active = true;
      WebUser connectedWebUser = await _userService.connect(cachedWebUser);
      cachedUser.update(connectedWebUser);

      // Then save in cache and update state
      _saveAndEmit(cachedUser);
    }

    // Otherwise emit NoUser state for OnboardingUi to build
    emit(NoUser());
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

    _saveAndEmit(connectedUser);
  }

  // Saves connected user to localDb, cache, and emits UserConnectSuccess state
  Future<void> _saveAndEmit(User connectedUser) async {
    await _dataService.saveUser(connectedUser);
    await _localCache.save('USER_ID', {'user_id': connectedUser.id.toString()});
    emit(UserConnectSuccess(connectedUser));
  }
}