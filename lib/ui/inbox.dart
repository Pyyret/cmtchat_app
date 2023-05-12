

import 'package:cmtchat_app/models/local/chat.dart';
import 'package:flutter/cupertino.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  late List<Chat> chatsList;

  @override
  Widget build(BuildContext context) {
    //context.read<HomeBloc>().add(SubscribeToChatListRequest());

    return BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is Initial) {
            chatsList = state.chatsList;
            return _buildList(context);
          }
          if (state is Initial) {
            const Center(child: CircularProgressIndicator());
          }
          print(state);
          return const Placeholder();
        });
  }

  _buildList(context) =>
      ListView.separated(
          padding: const EdgeInsets.only(top: 30.0, right: 16.0),
          itemBuilder: (_, indx) =>
              GestureDetector(
                child: _chatItem(chatsList[indx]),
                onTap: () => print('NO!'),
                    //context.read<HomeBloc>().add(ChatClicked(context: context, chat: chatsList[indx])),
              ),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: chatsList.length);

  _chatItem(Chat chat) =>
      ListTile(
        contentPadding: const EdgeInsets.only(left: 16.0),
        leading: const ProfilePlaceholder(50),
        title: Text(
          chat.chatName,
          style: Theme
              .of(context)
              .textTheme
              .titleSmall
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: isLightTheme(context) ? Colors.black : Colors.white,
          ),
        ),
        subtitle: Text(
          chat.lastMessageContents,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: Theme
              .of(context)
              .textTheme
              .labelSmall
              ?.copyWith(
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
              style: Theme
                  .of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                color:
                isLightTheme(context) ? Colors.black54 : Colors.white70,
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
                    style: Theme
                        .of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
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
