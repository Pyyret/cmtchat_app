import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/message_thread_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/collections/viewmodels_collection.dart';
import 'package:cmtchat_app/viewmodels/user_view_model.dart';

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

  // Blocs/Cubits
  static late WebMessageBloc _webMessageBloc;
  static late AppCubit _appCubit;
  static late HomeCubit2 _homeCubit2;
  static late ChatsCubit _chatsCubit;

  static late ChatsViewModel _chatsViewModel;
  static late UserViewModel _userViewModel;
  static late HomeViewModel _homeViewModel;

  static late IHomeRouter _homeRouter;



  static configure() async {
    final sp = await SharedPreferences.getInstance();
    _localCacheService = LocalCacheService(sp);
    _dataService = IsarService();

    _r = RethinkDb();
    _connection = await _r.connect(host: '172.21.0.1', port: 28015);

    _webUserService = WebUserService(_r, _connection);
    _webMessageService = WebMessageService(_r, _connection);

    _webMessageBloc = WebMessageBloc(_webMessageService);

    _userViewModel = UserViewModel(_webUserService, _dataService, _localCacheService);
    _homeViewModel = HomeViewModel(_dataService, _webUserService);
    _homeRouter = HomeRouter(showMessageThread: composeMessageThreadUi);

    _appCubit = AppCubit(_userViewModel);
    _homeCubit2 = HomeCubit2(_homeViewModel);


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
            if(state is UserConnectSuccess) { return composeHome(); }
            else {
              return const Onboarding();
            }
          },
        )
    );
  }


  static Widget composeHome() {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => _appCubit),
          BlocProvider(create: (BuildContext context) => _homeCubit2),
          BlocProvider(create: (BuildContext context) => _webMessageBloc),
          //BlocProvider(create: (BuildContext context) => _chatsCubit),
        ],
        child: HomeUi(_homeRouter),
    );
  }

  static Widget composeHomeUi(User mainUser) {
    HomeCubit homeCubit = HomeCubit(_webUserService);
    IHomeRouter router = HomeRouter(showMessageThread: composeMessageThreadUi);
    
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => homeCubit),
          BlocProvider(create: (BuildContext context) => _webMessageBloc),
          BlocProvider(create: (BuildContext context) => _chatsCubit),
        ],
        child: Home(mainUser, router)
    );
  }


  static Widget composeMessageThreadUi(User mainUser, Chat chat) {
    ChatViewModel viewModel = ChatViewModel(_dataService, mainUser);
    MessageThreadCubit messageThreadCubit = MessageThreadCubit(viewModel);
    IReceiptService receiptService = ReceiptService(_r, _connection);
    ReceiptBloc receiptBloc = ReceiptBloc(receiptService);

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => messageThreadCubit),
          BlocProvider(create: (BuildContext context) => receiptBloc),
        ],
        child: MessageThread(mainUser, chat,  _webMessageBloc, _homeCubit2),
    );
  }
}