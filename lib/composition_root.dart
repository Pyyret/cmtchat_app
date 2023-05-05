import 'package:cmtchat_app/cache/local_cache.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/services/local/data/isar_dataservice.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_impl.dart';
import 'package:cmtchat_app/services/web/receipt/receipt_service_contract.dart';
import 'package:cmtchat_app/services/web/receipt/receipt_service_impl.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_impl.dart';
import 'package:cmtchat_app/states_management/home/chats_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_cubit.dart';
import 'package:cmtchat_app/states_management/message_thread/message_thread_cubit.dart';
import 'package:cmtchat_app/states_management/receipt/receipt_bloc.dart';
import 'package:cmtchat_app/states_management/user_cubit/user_cubit.dart';
import 'package:cmtchat_app/states_management/user_cubit/user_state.dart';
import 'package:cmtchat_app/states_management/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/ui/pages/home/home.dart';
import 'package:cmtchat_app/ui/pages/home/home_router.dart';
import 'package:cmtchat_app/ui/pages/message_thread/message_thread_ui.dart';
import 'package:cmtchat_app/ui/pages/onboarding/onboarding.dart';
import 'package:cmtchat_app/viewmodels/chat_view_model.dart';
import 'package:cmtchat_app/viewmodels/chats_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/web/message/web_message_service_contract.dart';

class CompositionRoot {
  // Local services
  static late ILocalCache _localCache;
  static late IDataService _dataService;

  // Rethink webDb
  static late RethinkDb _r;
  static late Connection _connection;

  // Web services
  static late IWebUserService _webUserService;
  static late IWebMessageService _webMessageService;

  // Blocs/Cubits
  static late UserCubit _userCubit;
  static late WebMessageBloc _webMessageBloc;
  static late ChatsCubit _chatsCubit;

  static late ChatsViewModel _chatsViewModel;


  static configure() async {
    final sp = await SharedPreferences.getInstance();
    _localCache = LocalCache(sp);
    _dataService = IsarService();

    _r = RethinkDb();
    _connection = await _r.connect(host: '172.21.0.1', port: 28015);

    _webUserService = WebUserService(_r, _connection);
    _webMessageService = WebMessageService(_r, _connection);

    _webMessageBloc = WebMessageBloc(_webMessageService);
    _userCubit = UserCubit(_webUserService, _dataService, _localCache);

    // Testing
    //await sp.clear();
    //await _dataService.cleanDb();
  }


  static Future<Widget> director() async {
    return BlocProvider(
        create: (BuildContext context) => _userCubit,
        child: BlocConsumer<UserCubit, UserState>(

          listener: (context, state) async {
            if(state is UserInitial) {
              await context.read<UserCubit>().checkCache();
            }
            if(state is UserConnectSuccess) {
              _chatsViewModel = ChatsViewModel(_dataService, _webUserService,
                  state.user);
              _chatsCubit = ChatsCubit(_chatsViewModel);
            }},

          builder: (context, state) {
            if(state is UserConnectSuccess) { return composeHomeUi(state.user); }

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