import 'package:cmtchat_app/models/local/user.dart';
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
  final User mainUser;
  OnboardingSuccess(this.mainUser);
  @override
  List<Object> get props => [mainUser];
}