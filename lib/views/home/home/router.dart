import 'package:cmtchat_app/models/local/chat.dart';
import 'package:flutter/material.dart';

abstract class IRouter {
  Future<void> showChat(Chat chat);
}

class RouterCot implements IRouter {
  final BuildContext context;
  final Widget Function(Chat chat) onShowChat;

  RouterCot({required this.context, required this.onShowChat});

  @override
  Future<void> showChat(Chat chat) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => onShowChat(chat)),
    );
  }
}