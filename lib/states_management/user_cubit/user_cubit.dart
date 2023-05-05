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
      : super(UserInitial());


  Future<void> checkCache() async {
    // Check local cache for a previously logged in user
    final cachedUserId = _localCache.fetch('USER_ID');
    User? cachedUser = await _dataService
        .findUser(int.parse(cachedUserId['user_id']));

    // If found in the localDb => Update and connect to webserver
    if(cachedUserId.isNotEmpty && cachedUser != null) {
      emit(Loading());
      final webUser = WebUser.fromUser(cachedUser);
      webUser.lastSeen = DateTime.now();
      webUser.active = true;

      await _connectAndCache(webUser);
      return;
    }

    // Otherwise emit NoUser state for OnboardingUi to build
    emit(NoUser());
  }


  Future<void> create(String userName) async {
    emit(Loading());
    final webUser = WebUser(username: userName, lastSeen: DateTime.now(), active: true);
    _connectAndCache(webUser);
  }

  _connectAndCache(WebUser webUser) async {
    final connectedWebUser = await _userService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);
    await _dataService.saveUser(connectedUser);
    await _localCache.save('USER_ID', {
      'user_id' : connectedUser.id.toString(),
    });
    emit(UserConnectSuccess(connectedUser));
  }

}