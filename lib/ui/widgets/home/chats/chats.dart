import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/states_management/home/chats_cubit.dart';
import 'package:cmtchat_app/states_management/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/ui/pages/home/home_router.dart';
import 'package:cmtchat_app/ui/widgets/shared/profile_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Chats extends StatefulWidget {
  final User  user;
  final IHomeRouter router;

  const Chats(this.user, this.router, {super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  var chats = [];

  @override
  void initState() {
    super.initState();
    context.read<ChatsCubit>().chats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, List<Chat>>(
        builder: (_, chats) {
          this.chats = chats;
          if(this.chats.isEmpty) { return Container(); }
          return _buildListView();
        });
  }

  _buildListView() {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 30.0, right: 16.0),
        itemBuilder: (_, indx) => GestureDetector(
          child: _chatItem(chats[indx]),
          onTap: () async {
            await widget.router
                .onShowMessageThread(context, widget.user, chats[indx]);

            await context.read<ChatsCubit>().chats();
          },
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: chats.length);
  }

  _chatItem(Chat chat) => ListTile(
    contentPadding: const EdgeInsets.only(left: 16.0),
    leading: const ProfilePlaceholder(50),
    title: Text(
      chat.chatName ?? '',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: isLightTheme(context) ? Colors.black : Colors.white,
      ),
    ),
    subtitle: Text(
      chat.messages.last.contents,
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
          DateFormat('h:mm a').format(chat.lastUpdate),
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
