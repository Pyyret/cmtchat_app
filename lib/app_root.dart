import 'package:cmtchat_app/cubits/navigation_cubit.dart';
import 'package:cmtchat_app/cubits/web_user_cubit.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:cmtchat_app/services/local/data/isar_local_db.dart';
import 'package:cmtchat_app/services/local/data/local_db_api.dart';
import 'package:cmtchat_app/services/local/local_cache_service.dart';
import 'package:cmtchat_app/services/web/user/web_user_service.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';
import 'package:cmtchat_app/ui/home_view.dart';
import 'package:cmtchat_app/ui/login_view.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoot {
  // Rethink webDb
  static late RethinkDb _r;
  static late Connection _connection;

  // Local services
  static late ILocalCacheService _localCacheService;
  static late LocalDbApi _dataService;

  // Web services
  static late WebUserServiceApi _webUserService;

  static late AppRepository _repo;
  static late NavCubit _navCubit;

  static late WebUserCubit _webUserCubit;

  static configure() async {

    // Initializing
    final sp = await SharedPreferences.getInstance();
    _r = RethinkDb();
    _connection = await _r.connect(host: '172.21.0.1', port: 28015);

    // Local dataService APIs
    _localCacheService = LocalCacheService(sp);
    _dataService = IsarLocalDb();

    // WebDependant dataProvider APIs
    _webUserService = WebUserService(_r, _connection);


    _repo = AppRepository(
        localCache: _localCacheService,
        dataService: _dataService,
        webUserService: _webUserService);

    _navCubit = NavCubit(repository: _repo);
    _webUserCubit = WebUserCubit(repository: _repo);



  }

  static Widget director() {
    return RepositoryProvider(
      create: (BuildContext context) => _repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _navCubit),
        ],
        child: BlocBuilder<NavCubit, NavState>(
          builder: (context, state) {
            if(state.status == NavStatus.noUser) { return LogInView(); }
            else { return composeHomeView(); }
            }
        ),
      ),
    );
  }


  static Widget composeHomeView() =>
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => _webUserCubit),
        ],
        child: const HomeView(),
      );


}