import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/ui/widgets/shared/profile_placeholder.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  const Chats();

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 30.0, right: 16.0),
        itemBuilder: (_, indx) => _chatItem(),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: 3);
  }

  _chatItem() => ListTile(
    contentPadding: const EdgeInsets.only(left: 16.0),
    leading: ProfilePlaceholder(50),
    title: Text(
      'Lisa',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: isLightTheme(context) ? Colors.black : Colors.white,
      ),
    ),
    subtitle: Text(
      'Thank you!',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: isLightTheme(context) ? Colors.black54 : Colors.white70,
      ),
    ),
    trailing: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '12pm',
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
                '2',
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
