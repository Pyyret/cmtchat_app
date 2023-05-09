import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/collections/viewmodels_collection.dart';
import 'package:cmtchat_app/views/home/home/chat/chat_cubit/chat_cubit.dart';
import 'package:cmtchat_app/views/home/home/chat/chat_view.dart';

import 'package:cmtchat_app/views/home/shared_blocs/receipt_bloc/receipt_bloc.dart';
import 'package:cmtchat_app/views/home/shared_blocs/web_message/web_message_bloc.dart';

import 'package:flutter/cupertino.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CompositionRoot {
  // Local services
  static late ILocalCacheService _localCacheService;
  static late IDataService _dataService;

  // Rethink webDb
  static late RethinkDb _r;
  static late Connection _connection;

  // Web services
  static late IWebUserService _webUserService;
  static late IWebMessageService _webMessageService;
  static late IReceiptService _receiptService;

  // Blocs/Cubits
  static late AppCubit _appCubit;

  static late WebMessageBloc _webMessageBloc;
  static late ReceiptBloc _receiptBloc;


  static late HomeViewModel _homeViewModel;
  static late IHomeRouter _homeRouter;
  static late HomeCubit _homeCubit;



  static configure() async {
    final sp = await SharedPreferences.getInstance();
    _localCacheService = LocalCacheService(sp);
    _dataService = IsarService();

    _r = RethinkDb();
    _connection = await _r.connect(host: '172.21.0.1', port: 28015);

    _webUserService = WebUserService(_r, _connection);
    _webMessageService = WebMessageService(_r, _connection);
    _receiptService = ReceiptService(_r, _connection);

    _webMessageBloc = WebMessageBloc(_webMessageService);
    _receiptBloc = ReceiptBloc(_receiptService);

    _homeViewModel = HomeViewModel(_dataService, _webUserService,_receiptBloc);
    _homeRouter = HomeRouter(showMessageThread: composeMessageThreadUi);

    _appCubit = AppCubit(_webUserService, _dataService, _localCacheService);
    _homeCubit = HomeCubit(_homeViewModel);


    // Testing
    //await sp.clear();
    //await _dataService.cleanDb();
  }


  static BlocProvider<AppCubit> director() {
    return BlocProvider(
        create: (BuildContext context) => _appCubit,
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            if(state is AppInitial) { context.read<AppCubit>().loginFromCache(); }
            if(state is UserConnectSuccess) { return composeHomeUi(); }
            else { return const Onboarding(); }
          },
        )
    );
  }


  static Widget composeHomeUi() {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => _appCubit),
          BlocProvider(create: (BuildContext context) => _homeCubit),
          BlocProvider(create: (BuildContext context) => _webMessageBloc),
          BlocProvider(create: (BuildContext context) => _receiptBloc),
        ],
        child: Home(_homeRouter),
    );
  }


  static Widget composeMessageThreadUi(User user, Chat chat) {

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => _homeCubit),
          BlocProvider(create: (BuildContext context) => _webMessageBloc),
          BlocProvider(create: (BuildContext context) => ChatCubit(
              _dataService, _receiptBloc, user, chat)),
        ],
        child: const ChatView(),
    );
  }
}