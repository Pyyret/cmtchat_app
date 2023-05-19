import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/repository.dart';
import 'package:flutter/material.dart';


abstract class IRouter {
  Future<void> showChat(BuildContext context, Chat chat);
}

class RouterCot implements IRouter {
  final Repository repository;
  final Widget Function(Repository repository, Chat chat) onShowChat;

  RouterCot({required this.repository, required this.onShowChat});

  @override
  Future<void> showChat(BuildContext context, Chat chat) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => onShowChat(repository, chat)));
  }
}