import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:flutter/material.dart';

abstract class IRouter {
  Future<void> showChat(User user, Chat chat);
}

class RouterCot implements IRouter {
  final BuildContext context;
  final Widget Function(User user, Chat chat) onShowChat;

  RouterCot({required this.context, required this.onShowChat});

  @override
  Future<void> showChat(User user, Chat chat) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => onShowChat(user, chat),
        ),
    );
  }
}