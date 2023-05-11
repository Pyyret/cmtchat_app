import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/collections/viewmodels_collection.dart';

import 'package:cmtchat_app/repository/repository.dart';
import 'package:cmtchat_app/views/home/home/chat/chat_cubit/chat_cubit.dart';
import 'package:cmtchat_app/views/home/home/chat/chat_view.dart';

import 'package:cmtchat_app/views/home/shared_blocs/receipt_bloc/receipt_bloc.dart';
import 'package:cmtchat_app/views/home/shared_blocs/web_message/web_message_bloc.dart';

import 'package:flutter/cupertino.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubits_bloc/home_cubit.dart';

class CompositionRoot {
  // Rethink webDb
  static late RethinkDb _r;
  static late Connection _connection;

  // Local services
  static late ILocalCacheService _localCacheService;
  static late LocalDbApi _dataService;

  // Web services
  static late WebUserServiceApi _webUserService;
  static late WebMessageServiceApi _webMessageService;
  static late IReceiptService _receiptService;

  // Repository
  static late Repository _repository;

  // Routing data
  static late IRouter _router;

  // Blocs & Cubits
  static late AppCubit _appCubit;
  static late HomeBloc _homeBloc;
  static late WebMessageBloc _webMessageBloc;
  static late ReceiptBloc _receiptBloc;


  static late HomeViewModel _homeViewModel;


  /// Dependency Injections ///
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
    _webMessageService = WebMessageService(_r, _connection);
    _receiptService = ReceiptService(_r, _connection);

    // The repository binds everything together. It's a giant viewModel.
    // Its at the top of the widget tree (except for AppCubit), contains all
    // services, and is injected into all blocs & Cubits below.
    _repository = Repository(
        dataService: _dataService,
        webUserService: _webUserService,
        webMessageService: _webMessageService,
        receiptService: _receiptService,
    );

    // Exposing routing data, used by AppCubit
    _router = RouterCot(showMessageThread: composeMessageThreadUi);

    // Blocs & Cubits
    _appCubit = AppCubit(
        repository: _repository,
        router: _router,
        localCacheService: _localCacheService);

    _homeBloc = HomeBloc(repository: _repository);

    _webMessageBloc = WebMessageBloc(_webMessageService);
    _receiptBloc = ReceiptBloc(_receiptService);


    _homeViewModel = HomeViewModel(_dataService, _webUserService, _receiptBloc);

    // For testing, clears all local data
    await sp.clear();
    await _dataService.cleanDb();
  }


  static Widget director() =>
      MultiBlocProvider(
          providers: [
            BlocProvider(create: (BuildContext context) => _appCubit),
            BlocProvider(create: (BuildContext context) => _homeBloc),
            BlocProvider(create: (BuildContext context) => _webMessageBloc),
            BlocProvider(create: (BuildContext context) => _receiptBloc),
          ],
          child: RepositoryProvider(
              create: (context) => _repository,
              child: BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  switch(state.appView) {
                    case AppView.home: { return const Home(); } break;
                    default: { return const Onboarding(); }
                  }
                },
              )
          )
      );


  static Widget composeMessageThreadUi(User user, Chat chat) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => _homeBloc),
        BlocProvider(create: (BuildContext context) => _webMessageBloc),
        BlocProvider(
            create: (BuildContext context) =>
                ChatCubit(_dataService, _receiptBloc, user, chat)),
      ],
      child: const ChatView(),
    );
  }
/*

  static Widget composeHomeUi() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => _appCubit),
        BlocProvider(create: (BuildContext context) => _homeCubit),
        BlocProvider(create: (BuildContext context) => _webMessageBloc),
        BlocProvider(create: (BuildContext context) => _receiptBloc),
      ],
      child: OldHome(_router),
    );
  }
}
 */
}

