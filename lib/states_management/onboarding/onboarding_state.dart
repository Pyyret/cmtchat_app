import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {}

class OnboardingInitial extends OnboardingState {
  @override
  List<Object> get props => [];

}

class Loading extends OnboardingState {
  @override
  List<Object> get props => [];
}

class OnboardingSuccess extends OnboardingState {
  final WebUser _webUser;
  final User _user;
  OnboardingSuccess(this._webUser, this._user);
  @override
  List<Object> get props => [_webUser, _user];
}