import 'package:cmtchat_app/collections/cubits.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:flutter/material.dart';


class RouterCot {
  final HomeCubit homeCubit;
  final Widget Function(HomeCubit homeCubit, Chat chat) onShowChat;

  RouterCot({required this.homeCubit, required this.onShowChat});

  Future<void> showChat({required BuildContext context, required Chat chat}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => onShowChat(homeCubit, chat))
    );
  }
}