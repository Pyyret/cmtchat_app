import 'package:cmtchat_app/cubits/chat_cubit.dart';
import 'package:cmtchat_app/cubits/home_cubit.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/ui/shared_widgets/profile_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatAppBar extends StatelessWidget with PreferredSizeWidget{
  const ChatAppBar({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 8,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  context.read<ChatCubit>().close();
                  Navigator.of(context).pop();
                },
                iconSize: 30,
                icon: const Icon(Icons.arrow_back_ios_rounded),
                color: isLightTheme(context) ? Colors.black : Colors.white,
              ),
            ),
            Expanded(child: _headerStatus()),
          ],
        ),
      ),
    );
  }

  _headerStatus() {
    return Builder(builder: (context) {
      final receiver  = context.select((ChatCubit c) => c.receiver);
      final status = context.select((HomeCubit c) =>
          c.state.onlineUsers.any((webUser) => webUser.id == receiver.id));
      return SizedBox(
          width: double.maxFinite,
          child: Row(
              children: [
                const ProfilePlaceholder(50.0),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          receiver.username,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(status ? 'online' : 'offline',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 17)),
                      ],
                  ),
                ),
              ]
          )
      );
    });
  }
}
