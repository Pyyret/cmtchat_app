import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_impl.dart';
import 'package:cmtchat_app/states_management/home/home_cubit.dart';
import 'package:cmtchat_app/states_management/onboarding/onboarding_cubit.dart';
import 'package:cmtchat_app/ui/pages/home/home.dart';
import 'package:cmtchat_app/ui/pages/onboarding/onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompositionRoot {
  static late RethinkDb _r;
  static late Connection _connection;
  static late IWebUserService _webUserService;

  static configure() async {
    _r = RethinkDb();
    _connection = await _r.connect(host: '172.19.96.1', port: 28015);
    _webUserService = WebUserService(_r, _connection);
  }

  static Widget composeOnboardingUi() {
    OnboardingCubit onboardingCubit = OnboardingCubit(_webUserService);

    return MultiBlocProvider(
        providers: [BlocProvider(create: (BuildContext context) => onboardingCubit)],
        child: const Onboarding(),
    );
  }
  
  static Widget composeHomeUi() {
    HomeCubit homeCubit = HomeCubit(_webUserService);
    
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => homeCubit)
        ],
        child: const Home()
    );
  }

}