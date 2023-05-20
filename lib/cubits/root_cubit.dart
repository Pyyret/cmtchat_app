import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/services.dart';
import 'package:cmtchat_app/composition_root.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:equatable/equatable.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

/// Root State ///
class RootState extends Equatable {

  /// State variables
  final bool isLoggedIn;
  final Connection? connection;
  final User user;

  /// Constructors
  const RootState(this.isLoggedIn, this.connection, this.user);
  factory RootState.loggedOut() => RootState(false, null, User.empty());
  factory RootState.loggedIn({
    required Connection connection,
    required User activeUser
  }) => RootState(true, connection, activeUser);

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
        super(RootState.loggedOut())
  {
    // Initializing
    _initialize();
  }

  /// Public Methods
  // Looks for an already existing user with this username, if not found,
  // creates a new one.
  Future<void> logIn({required String username}) async {
    final dbUser = await _localDb.findUserWith(username: username);
    if(dbUser != null) {
      print('old user login start');
      _connectOldUserAndStart(dbUser);
    }
    else {
      final user = User(await _webUserService.connectNew(username));
      await _cacheAndStart(activeUser: user);
    }
  }

  // Closes the user specific connection, updates the webDb with active = false,
  // clears the cache, then emits the logged out state, thus presenting the
  // LogInView
  Future<void> logOut() async {
    state.connection?.close();
    final response = await _webUserService.update(
        webUser: state.user.webUser..active = false);
    if(state.user.isUpdatedFrom(webUser: response)) {
      await _localDb.putUser(state.user);
      await _localCache.clear();
      emit(RootState.loggedOut());
      //await _localDb.cleanDb();
    }
    else { print('User logout failed, webId: ${state.user.username}'); }
  }

  Future<WebUser> fetchWebUser({required String webUserId}) async {
    return await _webUserService.fetch([webUserId]).then((list) => list.single);
  }

  /// Private Methods
  Future<void> _initialize() async {
    _rootConnection = await _r.connect(host: _rAddress.host, port: _rAddress.port);
    _webUserService = WebUserService(_r, _rootConnection);
    _tryLoginFromCache();
  }

  // Checks local cache for a previously logged in user
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
      await _cacheAndStart(activeUser: user);
    }
  }

  // Saves connected user to localDb & cache, initializes repository
  // and emits a logged in root state with the resulting user.
  Future<void> _cacheAndStart({required User activeUser}) async {
    await _localDb.putUser(activeUser);
    await _localCache.save('USER_ID', {'user_id': activeUser.id.toString()});
    final connection = await _r
        .connect(host: _rAddress.host, port: _rAddress.port);

    emit(RootState.loggedIn(connection: connection, activeUser: activeUser));
  }
}