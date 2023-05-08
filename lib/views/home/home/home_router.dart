import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:flutter/material.dart';

abstract class IHomeRouter {
  Future<void> onShowMessageThread(BuildContext context, User mainUser, Chat chat);
}

class HomeRouter implements IHomeRouter {
  final Widget Function(User mainUser, Chat chat) showMessageThread;

  HomeRouter({required this.showMessageThread});

  @override
  Future<void> onShowMessageThread(BuildContext context, User user,
      Chat chat) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => showMessageThread(user, chat),
        ),
    );
  }

}