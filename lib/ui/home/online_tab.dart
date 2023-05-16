import 'package:cmtchat_app/cubits/home_cubit.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/ui/shared_widgets/profile_placeholder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnlineTab extends StatelessWidget {
  const OnlineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<WebUser> onlineUsers = context.select(
            (HomeCubit c) => c.state.onlineUsers);
    return ListView.separated(
      padding: const EdgeInsets.only(top: 30.0, right: 16.0),
      itemBuilder: (_, indx) => GestureDetector(
        child: _listItem(context, onlineUsers[indx]),
        onTap: () => context.read<HomeCubit>().routeChatFromWebUser(onlineUsers[indx]),
      ),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: onlineUsers.length,
    );
  }


  _listItem(context, WebUser user) => ListTile(
    leading: const ProfilePlaceholder(50),
    title: Text(
      user.username,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );


}

