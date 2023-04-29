import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';

import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final IWebUserService _userService;

  OnboardingCubit(this._userService) : super(OnboardingInitial());

  Future<void> connect(String name) async {
    emit(Loading());
    final webUser = WebUser(
        username: name,
        photoUrl: '',
        active: true,
        lastSeen: DateTime.now()
    );
    final createdUser = await _userService.connect(webUser);
    emit(OnboardingSuccess(createdUser));
  }
}