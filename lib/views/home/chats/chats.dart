import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/theme.dart';

import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/views/shared_widgets/profile_placeholder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Chats extends StatefulWidget {
  final User _user;
  final IHomeRouter _homeRouter;
  const Chats(this._user, this._homeRouter, {super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late final User _user;
  late final IHomeRouter _router;

  @override
  void initState() {
    super.initState();
    _router = widget._homeRouter;
    _user = widget._user;
  }

  @override
  Widget build(BuildContext context) {
    final List<Chat> chatList = context.select(
            (HomeCubit2 cubit) => cubit.state.chatList);
    return ListView.separated(
        padding: const EdgeInsets.only(top: 30.0, right: 16.0),
        itemBuilder: (_, indx) => GestureDetector(
          child: _chatItem(chatList[indx]),
          onTap: () async {
            await _router.onShowMessageThread(context, _user, chatList[indx]);
          },
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: chatList.length
    );
  }

  _chatItem(Chat chat) => ListTile(
    contentPadding: const EdgeInsets.only(left: 16.0),
    leading: const ProfilePlaceholder(50),
    title: Text(
      chat.chatName,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: isLightTheme(context) ? Colors.black : Colors.white,
      ),
    ),
    subtitle: Text(
      chat.lastMessageContents,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: isLightTheme(context) ? Colors.black54 : Colors.white70,
        fontWeight: chat.unread > 0 ? FontWeight.bold : FontWeight.normal,
      ),
    ),
    trailing: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('h:mm a').format(
              chat.lastUpdate),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isLightTheme(context) ? Colors.black54 : Colors.white70,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 15.0,
              width:  15.0,
              color: kPrimary,
              alignment: Alignment.center,
              child: Text(
                chat.unread.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
