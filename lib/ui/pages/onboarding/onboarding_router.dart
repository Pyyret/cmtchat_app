import 'package:cmtchat_app/models/local/user.dart';
import 'package:flutter/material.dart';

abstract class IOnboardingRouter {
  void onSessionSuccess(BuildContext context, User mainUser);
}

class OnboardingRouter implements IOnboardingRouter {
  final Widget Function(User mainUser) onSessionConnected;

  OnboardingRouter(this.onSessionConnected);

  @override
  void onSessionSuccess(BuildContext context, User mainUser) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => onSessionConnected(mainUser)),
            (Route<dynamic> route) => false);
  }

}