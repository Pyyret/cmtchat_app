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

/// RethinkDbAddress ///
// For simplifying rethinkDb address specification.
class RethinkDbAddress {
  RethinkDbAddress({required this.host, required this.port});
  final String host;
  final int port;
}

/// Composition Root ///
// Dependency injection overview
class CompositionRoot {

  /// Static global variables
  static late LocalCacheApi _localCacheService;
  static late LocalDbApi _localDb;
  static late RethinkDb _r;
  static late RethinkDbAddress _rAddress;
  static late RootCubit _rootCubit;

  /// Configure ///
  // Initializes and configures the static and globally accessible variables
  static configure(RethinkDbAddress address) async {

    /// Local data providers
    final sp = await SharedPreferences.getInstance();
    _localCacheService = LocalCacheService(sp);
    _localDb = LocalDbIsar();

    /// RethinkDb web database
    _r = RethinkDb();
    _rAddress = address;

    /// RootCubit
    // Responsible for logging users in or out. At startup it will checks the
    // local cache for a previously logged in user. If not found it will wait
    // for a login attempt.
    _rootCubit = RootCubit(
      localCacheService: _localCacheService,
      localDbService: _localDb,
      rethinkDb: _r,
      rethinkDbAddress: _rAddress
    );

  }

  /// App Root ///
  // When a user is logged in the BlocBuilder will call the 'composeApp'
  // method the user and a user-specific database connection.
  // If no user is logged in, it will show the 'LogInView'.
  static Widget root() {
    return BlocProvider.value(
        value: _rootCubit,
        child: BlocBuilder<RootCubit, RootState>(
            builder: (_,state) => state.isLoggedIn
                ? composeApp(state.connection!, state.user)
                : const LogInView()
        )
    );
  }

  /// Compose App ///
  // Sets up the user-specific services, repository & HomeCubit.
  static Widget composeApp(Connection connection, User activeUser) {

    /// Web database-dependent services
    // They all use the same connection, given by the RootCubit
    final webUserService = WebUserService(_r, connection);
    final webMessageService = WebMessageService(_r, connection);
    final receiptService = ReceiptService(_r, connection);

    /// Repository
    // Responsible for receiving messages and message receipts
    final repository = Repository(
      activeUser: activeUser,
      dataService: _localDb,
      webMessageService: webMessageService,
      receiptService: receiptService,
      rootCubit: _rootCubit,
    );

    /// HomeCubit
    // Responsible for connecting the ui and the repository
    final homeCubit = HomeCubit(
        repository: repository,
        webUserService: webUserService
    );

    /// Router
    // Used in the HomeView when a chat is clicked. Provides the 'composeChat'
    // widget with the HomeCubit.
    final router = RouterCot(homeCubit: homeCubit, onShowChat: composeChat);

    /// HomeView
    // Finally, the HomeView is shown.
    // BlocProvider makes sure the HomeCubit is accessible throughout.
    return BlocProvider.value(
      value: homeCubit,
      child: HomeView(router: router),
    );
  }

  /// Compose Chat ///
  // Takes in a chat and the HomeCubit, and presents the ChatView
  static Widget composeChat(HomeCubit homeCubit, Chat chat) {

    /// ChatCubit
    final chatCubit = ChatCubit(repository: homeCubit.repository, chat: chat);

    /// ChatView
    // MultiBlocProvider makes both the HomeCubit and the ChatCubit available
    // throughout the ChatView.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: homeCubit),
        BlocProvider.value(value: chatCubit),
      ],
      child: ChatView(),
    );
  }

}
