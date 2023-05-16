import 'package:cmtchat_app/cubits/home_cubit.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/ui/shared_widgets/profile_placeholder.dart';
import 'package:cmtchat_app/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';


class InboxTab extends StatelessWidget {
  const InboxTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Chat> chatsList = context.select(
            (HomeCubit c) => c.state.chatsList);
    return ListView.separated(
        padding: const EdgeInsets.only(top: 30.0, right: 16.0),
        itemBuilder: (_, indx) =>
            GestureDetector(
              child: _chatItem(context, chatsList[indx]),
              onTap: () => context.read<HomeCubit>().routeChat(chatsList[indx]),
            ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: chatsList.length
    );
  }

  _chatItem(context, Chat chat) =>
      ListTile(
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
            fontWeight:
            chat.unread > 0 ? FontWeight.bold : FontWeight.normal,
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
                  width: 15.0,
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
