import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';

import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final IWebUserService _userService;
  final IDataService _dataService;

  OnboardingCubit(this._userService, this._dataService) : super(OnboardingInitial());

  Future<void> connect(String name) async {
    emit(Loading());
    final webUser = WebUser(
        username: name,
        photoUrl: '',
        active: true,
        lastSeen: DateTime.now()
    );
    final createdWebUser = await _userService.connect(webUser);
    final createdUser = User.fromWebUser(webUser: createdWebUser);
    _dataService.saveUser(createdUser);
    emit(OnboardingSuccess(createdWebUser, createdUser));
  }
}