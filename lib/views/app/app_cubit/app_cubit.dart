import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/repository/repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

/// AppState ///
class AppState extends Equatable {
  final bool userLoggedIn;
  final AppStatus appStatus;
  final AppView appView;
  final User? appUser;
  final int? singleChatId;

  const AppState({
    this.userLoggedIn = false,
    this.appStatus = AppStatus.offline,
    this.appView = AppView.onboarding,
    this.appUser,
    this.singleChatId
  });

  AppState copyWith({
    bool? userLoggedIn,
    AppStatus? appStatus,
    AppView? appView,
    User? appUser,
    int? singleChatId,
  }) {
    return AppState(
      userLoggedIn : userLoggedIn ?? this.userLoggedIn,
      appStatus: appStatus ?? this.appStatus,
      appView: appView ?? this.appView,
      appUser: appUser ?? this.appUser,
      singleChatId: singleChatId ?? this.singleChatId,
    );
  }

  /// AppState Factories ///
  init() => const AppState(
      userLoggedIn: false,
      appStatus: AppStatus.offline,
      appView: AppView.onboarding,
      appUser: null);

  loading() => copyWith(
      appStatus: AppStatus.loading);

  logInSuccess({required User user}) => copyWith(
      userLoggedIn: true,
      appStatus: AppStatus.online,
      appView: AppView.home,
      appUser: user);

  chatRouted({required int singleChatId}) => copyWith(
    appStatus: AppStatus.online,
    appView: AppView.singleChat,
    singleChatId: singleChatId,
  );

  /// State variables ///
  @override
  List<Object?> get props => [userLoggedIn, appStatus, appView, appUser, singleChatId];
}

/// Enum ///
enum AppStatus { loading, online, offline, logOutRequested }
enum AppView { onboarding, home, singleChat, settings }


/// AppCubit ///
class AppCubit extends Cubit<AppState> {
  final Repository _repository;
  final IRouter _router;
  final ILocalCacheService _localCacheService;

  AppCubit({
    required Repository repository,
    required IRouter router,
    required ILocalCacheService localCacheService
  }) : _repository = repository,
        _router = router,
        _localCacheService = localCacheService,
        super(const AppState().init())

  { _loginFromCache(); } // Tries to login from cache as soon as its constructed



  /// Methods ///
  Future<void> routeChat(context, chat) async {
    emit(state.loading());
    await _router.onShowMessageThread(context, state.appUser!, chat);
    emit(state.chatRouted(singleChatId: chat.id));
  }


  Future<void> _loginFromCache() async {
    emit(state.loading());

    // Check local cache for a previously logged in user
    final cachedUserId = _localCacheService.fetch('USER_ID');

    // If cachedUserId is not empty,
    // check localDb for user with the cashed user id.
    User? cachedUser;
    if(cachedUserId.isNotEmpty) {
      cachedUser = await _repository.localDb.getUser(int.parse(cachedUserId['user_id']));
    }

    // If found in localDb => connect & save user, then emit UserConnectSuccess
    if(cachedUser != null) {
      User connectedUser = await _connect(cachedUser);
      final User savedUser = await _cacheAndSave(connectedUser);
      emit(state.logInSuccess(user: savedUser));
    }
    else { emit(state.init()); }
  }


  // Creates a new User, connects and saves it, from username entered
  // in the OnboardingUi.
  Future<void> newUserLogin(String username) async {
    emit(state.loading());
    User connectedUser = await _connectNewUser(username);
    final User savedUser = await _cacheAndSave(connectedUser);
    emit(state.logInSuccess(user: savedUser));
  }


  Future<User> _connectNewUser(String userName) async {
    final webUser = WebUser(
        username: userName,
        lastSeen: DateTime.now(),
        active: true
    );

    WebUser connectedWebUser = await _repository.webUserService.connect(webUser);
    User connectedUser = User.fromWebUser(webUser: connectedWebUser);
    return connectedUser;
  }


  Future<User> _connect(User localUser) async {
    // Create a WebUser from the cachedUser and update relevant variables
    final webUser = WebUser.fromUser(localUser)
      ..lastSeen = DateTime.now()
      ..active = true;

    // Connect to webserver, then update the local cachedUser
    WebUser connectedWebUser = await _repository.webUserService.connect(webUser);
    localUser.update(connectedWebUser);
    return localUser;
  }


  // Saves connected user to localDb & cache
  Future<User> _cacheAndSave(User connectedUser) async {
    await _repository.localDb.saveUser(connectedUser);
    await _localCacheService.save('USER_ID', {'user_id': connectedUser.id.toString()});
    return connectedUser;
  }
}