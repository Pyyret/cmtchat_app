import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/services.dart';
import 'package:cmtchat_app/composition_root.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:equatable/equatable.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

/// Root State ///
class RootState extends Equatable {
  /// Constructor
  const RootState({
    required this.isLoggedIn,
    required this.connection,
    required this.user});

  /// State variables
  final bool isLoggedIn;
  final Connection? connection;
  final User user;


  @override
  List<Object?> get props => [isLoggedIn, connection, user];
}

/// Root Cubit ///
class RootCubit extends Cubit<RootState> {

  /// Data Providers
  final LocalCacheApi _localCache;
  final LocalDbApi _localDb;
  late final WebUserServiceApi _webUserService;

  /// Private Variables
  final RethinkDb _r;
  final RethinkDbAddress _rAddress;
  late final Connection _rootConnection;


  /// Constructor
  RootCubit({
    required LocalCacheApi localCacheService,
    required LocalDbApi localDbService,
    required RethinkDb rethinkDb,
    required RethinkDbAddress rethinkDbAddress
  })
      : _localCache = localCacheService,
        _localDb = localDbService,
        _r = rethinkDb,
        _rAddress = rethinkDbAddress,
        super(RootState(isLoggedIn: false, connection: null , user: User.empty()))
  {
    // Initializing
    _initialize();
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
    state.connection?.close();
    final response = await _webUserService.update(
        webUser: state.user.webUser..active = false);
    if(state.user.isUpdatedFrom(webUser: response)) {
      print('User logout success, webId: ${state.user.webId}');
      await _localDb.putUser(state.user);
      await _localCache.clear();
      emit(RootState(isLoggedIn: false, connection: null, user: state.user));
      //await _localDb.cleanDb();
    }
    else { print('User logout failed, webId: ${state.user.webId}'); }
  }

  Future<WebUser> fetchWebUser({required String webUserId}) async {
    return await _webUserService.fetch([webUserId]).then((list) => list.single);
  }

  /// Local Methods ///
  Future<void> _initialize() async {
    _rootConnection = await _r.connect(host: _rAddress.host, port: _rAddress.port);
    _webUserService = WebUserService(_r, _rootConnection);
    _tryLoginFromCache();
  }

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
    final userConnection = await _r
        .connect(host: _rAddress.host, port: _rAddress.port);

    emit(RootState(isLoggedIn: true, connection: userConnection, user: connectedUser));
  }
}