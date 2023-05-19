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
    _rAddress = RethinkDbAddress(host: '172.29.32.1', port: 28015);

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
            builder: (context, state) => !state.isLoggedIn
                ? const LogInView() : composeApp(state)
        )
    );
  }


  static Widget composeApp(RootState state) {
    final connection = state.connection!;
    final webUserService = WebUserService(_r, connection);
    final webMessageService = WebMessageService(_r, connection);
    final receiptService = ReceiptService(_r, connection);

    final repository = Repository(
      activeUser: state.user,
      dataService: _localDb,
      webMessageService: webMessageService,
      receiptService: receiptService,
      rootCubit: _rootCubit,
    );

    final router = RouterCot(repository: repository, onShowChat: composeChat);

    return BlocProvider(create: (BuildContext context) => HomeCubit(
        repository: repository,
        webUserService: webUserService,
        router: router
    ),
      child: const HomeView(),
    );
  }

  static Widget composeChat(Repository repository, Chat chat) {
    return BlocProvider(create: (BuildContext context) {
      return ChatCubit(
          repository: repository,
          chat: chat
      );
    },
      child: ChatView(),
    );
  }
}
