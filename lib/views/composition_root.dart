import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/message_thread_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/collections/viewmodels_collection.dart';

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
  static late AppCubit _userCubit;
  static late WebMessageBloc _webMessageBloc;

  static late ChatsCubit _chatsCubit;
  static late ChatsViewModel _chatsViewModel;

  static late HomeViewModel _homeViewModel;



  static configure() async {
    final sp = await SharedPreferences.getInstance();
    _localCacheService = LocalCacheService(sp);
    _dataService = IsarService();

    _r = RethinkDb();
    _connection = await _r.connect(host: '172.21.0.1', port: 28015);

    _webUserService = WebUserService(_r, _connection);
    _webMessageService = WebMessageService(_r, _connection);

    _webMessageBloc = WebMessageBloc(_webMessageService);
    _userCubit = AppCubit(_webUserService, _dataService, _localCacheService);

    _homeViewModel = HomeViewModel(_dataService, _webUserService);

    // Testing
    //await sp.clear();
    //await _dataService.cleanDb();
  }


  static Future<Widget> director() async {
    return BlocProvider(
        create: (BuildContext context) => _userCubit,
        child: BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {
            if(state is UserConnectSuccess) {
              /*
              _chatsViewModel = ChatsViewModel(
                  _dataService, _webUserService, state.user);
              _chatsCubit = ChatsCubit(_chatsViewModel);

               */
            }},

          builder: (context, state) {
            if(state is AppInitial) { context.read<AppCubit>().checkCache(); }
            if(state is UserConnectSuccess) { return composeHome(state.user); }

            return composeOnboardingUi();
          },
        ),
    );
  }

  static Widget composeOnboardingUi() {
    return BlocProvider(
      create: (BuildContext context) => _userCubit,
      child: const Onboarding(),
    );
  }


  static Widget composeHome(User user) {
    HomeCubit2 homeCubit2 = HomeCubit2(user, _homeViewModel);

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => _userCubit),
          BlocProvider(create: (BuildContext context) => homeCubit2),
          //BlocProvider(create: (BuildContext context) => _webMessageBloc),
          //BlocProvider(create: (BuildContext context) => _chatsCubit),
        ],
        child: HomeUi(user),
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
        child: MessageThread(mainUser,chat,  _webMessageBloc, _chatsCubit),
    );
  }
}