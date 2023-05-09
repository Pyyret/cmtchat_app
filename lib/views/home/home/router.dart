import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:flutter/material.dart';

abstract class IRouter {
  Future<void> onShowMessageThread(BuildContext context, User user, Chat chat);
}

class RouterCot implements IRouter {
  final Widget Function(User user, Chat chat) showMessageThread;

  RouterCot({required this.showMessageThread});

  @override
  Future<void> onShowMessageThread(BuildContext context, User user, Chat chat) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => showMessageThread(user, chat),
        ),
    );
  }
}