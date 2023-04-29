import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/services/local/data/isar_dataservice.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_impl.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_impl.dart';
import 'package:cmtchat_app/states_management/home/chats_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_cubit.dart';
import 'package:cmtchat_app/states_management/onboarding/onboarding_cubit.dart';
import 'package:cmtchat_app/states_management/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/ui/pages/home/home.dart';
import 'package:cmtchat_app/ui/pages/onboarding/onboarding.dart';
import 'package:cmtchat_app/viewmodels/chats_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'services/web/message/web_message_service_contract.dart';

class CompositionRoot {
  static late RethinkDb _r;
  static late Connection _connection;
  static late IWebUserService _webUserService;
  static late IDataService _dataService;
  static late IWebMessageService _webMessageService;

  static late User _user;

  static configure() async {
    _r = RethinkDb();
    _connection = await _r.connect(host: '172.19.96.1', port: 28015);
    _webUserService = WebUserService(_r, _connection);
    _dataService = IsarService();
    _webMessageService = WebMessageService(_r, _connection);

    // Testing
    _dataService.cleanDb();
    _user = User(
      webUserId: 'e75d1fb5-3961-498f-bb21-45ec8727e697',
      username: 'Tor',
      photoUrl: '',
      active: true,
      lastSeen: DateTime.now(),
    );

  }

  static Widget composeOnboardingUi() {
    OnboardingCubit onboardingCubit = OnboardingCubit(_webUserService, _dataService);

    return MultiBlocProvider(
        providers: [BlocProvider(create: (BuildContext context) => onboardingCubit)],
        child: const Onboarding(),
    );
  }
  
  static Widget composeHomeUi() {
    HomeCubit homeCubit = HomeCubit(_webUserService);
    WebMessageBloc webMessageBloc = WebMessageBloc(_webMessageService);
    ChatsViewModel viewModel = ChatsViewModel(_dataService, _webUserService, _user);
    ChatsCubit chatsCubit = ChatsCubit(viewModel);
    
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => homeCubit),
          BlocProvider(create: (BuildContext context) => webMessageBloc),
          BlocProvider(create: (BuildContext context) => chatsCubit),
        ],
        child: const Home()
    );
  }

}