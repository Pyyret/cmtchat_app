
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/repository.dart';
import 'package:cmtchat_app/collections/cubits.dart';
import 'package:cmtchat_app/collections/services.dart';
import 'package:cmtchat_app/models/local/chat.dart';

import 'package:cmtchat_app/ui/chat/chat_view.dart';
import 'package:cmtchat_app/ui/home/home_view.dart';
import 'package:cmtchat_app/ui/login_view.dart';
import 'package:cmtchat_app/ui/router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubits/message_cubit.dart';

/// Composition Root ///
// Dependency injection overview
class CompositionRoot {

  // Local services
  static late LocalCacheApi _localCacheService;
  static late LocalDbApi _localDb;

  // Rethink WebDataBase
  static late RethinkDb _r;
  static late Connection _connection;

  // Web services
  static late WebUserServiceApi _webUserService;
  static late WebMessageService _webMessageService;

  static late RootCubit _rootCubit;

  /// Configures & initializes app-wide data providers & Root Cubit ///
  static configure() async {

    /// Local data providers
    final sp = await SharedPreferences.getInstance();
    _localCacheService = LocalCacheService(sp);
    _localDb = LocalDbIsar();

    /// Rethink database
    _r = RethinkDb();
    _connection = await _r.connect(host: '172.29.32.1', port: 28015);


    _webMessageService = WebMessageService(_r, _connection);
    /// Root Cubit
    _webUserService = WebUserService(_r, _connection);
    _rootCubit = RootCubit(
      connection: _connection,
      localCacheService: _localCacheService,
      dataService: _localDb,
      webUserService: _webUserService,
    );
  }

  static Widget root() {
    return BlocProvider.value(
      value: _rootCubit,
      child: BlocBuilder<RootCubit, RootState>(
        builder: (context, state) => state.isLoggedIn
            ? composeApp(state.user) : const LogInView(),
      ),
    );
  }

  static Widget composeApp(User activeUser) {

    final repository = Repository(
      activeUser: activeUser,
      dataService: _localDb,
      webMessageService: _webMessageService,
      receiptService: ReceiptService(_r, _connection),
      rootCubit: _rootCubit,
    );

    final router = RouterCot(repository: repository, onShowChat: composeChat);

    return MultiBlocProvider(
        providers: [
        BlocProvider(create: (BuildContext context) =>
        MessageCubit(
            repository: repository,
            webMessageService: _webMessageService
        ),
        ),
          BlocProvider(create: (context) =>
              HomeCubit(
                  repository: repository,
                  router: router,
                  webUserService: _webUserService)
          )
        ],
        child: const HomeView()
    );
  }

  /*
    BlocProvider(
      create: (context) {
        final repository = Repository(
          activeUser: activeUser,
          dataService: _localDb,
          webMessageService: _webMessageService,
          receiptService: ReceiptService(_r, _connection),
          rootCubit: _rootCubit,
        );

        final router = RouterCot(repository: repository, onShowChat: composeChat);

        return HomeCubit(
            repository: repository,
            router: router,
            webUserService: _webUserService);

      },
      child: const HomeView(),
    );
  }

   */

  static Widget composeChat(Repository repository, Chat chat) {
    return BlocProvider(
        create: (_) {
          return ChatCubit(
            repository: repository,
            chat: chat,
          );
        },
      child: ChatView(),
    );
  }
}
