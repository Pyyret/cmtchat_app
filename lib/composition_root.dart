
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

import '_deprecated/message_cubit.dart';

/// Composition Root ///
// Dependency injection overview
class CompositionRoot {

  static late LocalCacheApi _localCacheService;
  static late LocalDbApi _localDb;
  static late RethinkDb _r;
  static late RethinkDbAddress _rAddress;
  static late RootCubit _rootCubit;

  /// Initializes persistent data providers & Root Cubit ///
  static configure() async {

    /// Local data providers
    final sp = await SharedPreferences.getInstance();
    _localCacheService = LocalCacheService(sp);
    _localDb = LocalDbIsar();

    /// RethinkDb service
    _r = RethinkDb();
    // For opening and closing the connection to RethinkDb
    _rAddress = const RethinkDbAddress(
        host: '172.29.32.1',
        port: 28015
    );

    /// RootCubit
    _rootCubit = RootCubit(
      localCacheService: _localCacheService,
      localDbService: _localDb,
      rethinkDb: _r,
      rethinkDbAddress: _rAddress
    );

  }

  static Widget root() {
    return BlocProvider.value(
        value: _rootCubit,
        child: BlocBuilder<RootCubit, RootState>(
            builder: (BuildContext context, state) => !state.isLoggedIn
                ? const LogInView() : composeApp(context)

        )
    );
  }


  static Widget composeApp(BuildContext context) {
    final user = context.read<RootCubit>().state.user;
    final connection = context.read<RootCubit>().connection;
    final repository = Repository(
        activeUser: user,
        dataService: _localDb,
        webMessageService: WebMessageService(_r, connection),
        receiptService: ReceiptService(_r, connection),
        rootCubit: context.read<RootCubit>(),
    );

    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider(
          create: (context) => HomeCubit(
              repository: repository,
              webUserService: WebUserService(_r, connection),
              router: RouterCot(
                repository: repository,
                onShowChat: composeChat,
              )
          ),
        child: const HomeView(),
      )
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
