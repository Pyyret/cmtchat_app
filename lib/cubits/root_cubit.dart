import 'package:bloc/bloc.dart';

import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/local_cache_service.dart';
import 'package:cmtchat_app/services/local/local_db_api.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';
import 'package:equatable/equatable.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

/// Root State ///
class RootState extends Equatable {
  /// Constructor
  const RootState({required this.isLoggedIn, required this.user});

  /// State variables
  final bool isLoggedIn;
  final User user;

  @override
  List<Object> get props => [isLoggedIn, user];
}

/// Root Cubit ///
class RootCubit extends Cubit<RootState> {

  /// Data Providers
  final LocalCacheApi _localCache;
  final LocalDbApi _localDb;
  final WebUserServiceApi _webUserService;
  final Connection connection;

  /// Constructor
  RootCubit({
    required this.connection,
    required LocalCacheApi localCacheService,
    required LocalDbApi dataService,
    required WebUserServiceApi webUserService,})
      : _localCache = localCacheService,
        _localDb = dataService,
        _webUserService = webUserService,
        super(RootState(isLoggedIn: false, user: User.empty()))
  {
    // Initializing
    _tryLoginFromCache();
  }


  /// Methods ///
  // Creates a new User from username entered in the OnboardingUi, connects
  // and saves it, returns the new user
  Future<void> logIn({required String username}) async {
    final dbUser = await _localDb.findUserWith(username: username);
    if(dbUser != null) {
      print('old user login start');
      _connectOldUserAndStart(dbUser);
    }
    else {
      final user = User(await _webUserService.connectNew(username));
      await _cacheAndStart(connectedUser: user);
    }
  }

  Future<void> logOut() async {

    //await _repo.reset();
    final response = await _webUserService
        .update(webUser: state.user.webUser..active = false);
    if(state.user.isUpdatedFrom(webUser: response)) {
      print('User logout success, webId: ${state.user.webId}');
      await _localDb.putUser(state.user);
      await _localCache.clear();
      emit(RootState(isLoggedIn: false, user: state.user));
      //await _localDb.cleanDb();
    }
    else { print('User logout failed, webId: ${state.user.webId}'); }
  }

  Future<WebUser> fetchWebUser({required String webUserId}) async {
    return await _webUserService.fetch([webUserId]).then((list) => list.single);
  }

  /// Local Methods ///
  // Check local cache for a previously logged in user and fetch it from
  // the local db. If found, update relevant variables and cache, connect
  // to webserver and return the user.
  Future<void> _tryLoginFromCache() async {
    final userId = _localCache.fetch('USER_ID');
    if(userId.isNotEmpty) {
      User? user = await _localDb.findUser(userId: int.parse(userId['user_id']));
      if(user != null) {
        print('cached user found');
        await _connectOldUserAndStart(user);
      }
    }
  }

  // Connects an already existing user
  Future<void> _connectOldUserAndStart(User user) async {
    user.webUser.active = true;
    final response = await _webUserService.update(webUser: user.webUser);
    if(user.isUpdatedFrom(webUser: response)) {
      await _cacheAndStart(connectedUser: user);
    }
    else { print('Failed to connect old user'); }
  }

  // Saves connected user to localDb & cache, initializes repository
  // and emits a logged in root state with the resulting user.
  Future<void> _cacheAndStart({required User connectedUser}) async {
    await _localDb.putUser(connectedUser);
    await _localCache.save('USER_ID', {'user_id': connectedUser.id.toString()});
    emit(RootState(isLoggedIn: true, user: connectedUser));
  }
}