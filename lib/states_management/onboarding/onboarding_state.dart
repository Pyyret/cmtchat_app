import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {}

class OnboardingInitial extends OnboardingState {
  @override
  List<Object?> get props => [];

}

class Loading extends OnboardingState {
  @override
  List<Object?> get props => [];
}

class OnboardingSuccess extends OnboardingState {
  final WebUser _user;
  OnboardingSuccess(this._user);
  @override
  List<Object?> get props => [_user];
}