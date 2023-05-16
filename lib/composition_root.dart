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


class CompositionRoot {

  // Rethink webDb
  static late RethinkDb _r;
  static late Connection _connection;

  // Local services
  static late LocalCacheApi _localCacheService;
  static late LocalDbApi _dataService;

  // Web services
  static late WebUserServiceApi _webUserService;
  static late WebMessageServiceApi _webMsgServ;
  static late ReceiptServiceApi _receiptService;

  static late Repository _repo;


  static late UserCubit _userCubit;

  static configure() async {

    // Initializing
    final sp = await SharedPreferences.getInstance();
    _r = RethinkDb();
    _connection = await _r.connect(host: '172.17.112.1', port: 28015);

    // Local dataService APIs
    _localCacheService = LocalCacheService(sp);
    _dataService = LocalDbIsar();

    // WebDependant dataProvider APIs
    _webUserService = WebUserService(_r, _connection);
    _webMsgServ = WebMessageService(_r, _connection);
    _receiptService = ReceiptService(_r, _connection);

    _repo = Repository(
        localCache: _localCacheService,
        dataService: _dataService,
        webUserService: _webUserService,
        webMessageService: _webMsgServ,
        receiptService: _receiptService,
    );

    _userCubit = UserCubit(repository: _repo);

  }

  static Widget director() {
    return RepositoryProvider(
        create: (BuildContext context) => _repo,
        child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => _userCubit),
            ],
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                return state is UserLoggedIn
                    ? composeHomeView()
                    : const LogInView();
              } ,
            )
        ),
    );
  }


  static Widget composeHomeView() {
    return BlocProvider(
      create: (BuildContext context) {
        final IRouter router = RouterCot(
            context: context,
            onShowChat: composeChatView);
        return HomeCubit(
            repository: _repo,
            router: router,
            webUserService: _webUserService);
      },
      child: const HomeView(),
    );
  }

  static Widget composeChatView(Chat chat) {
    return MultiBlocProvider(
        providers: [
        BlocProvider(create:(BuildContext context) => ChatCubit(
            repository: _repo,
            chat: chat)),
        ],
        child: ChatView(),
    );
  }
}