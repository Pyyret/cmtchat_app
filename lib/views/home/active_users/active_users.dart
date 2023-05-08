import 'package:cmtchat_app/collections/home_cubit_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';

import 'package:cmtchat_app/views/home/home/home_router.dart';
import 'package:cmtchat_app/views/shared_widgets/profile_placeholder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveUsers extends StatefulWidget {
  final User _user;
  final IHomeRouter _homeRouter;
  const ActiveUsers(this._user, this._homeRouter, {super.key});

  @override
  State<ActiveUsers> createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  late final IHomeRouter router;
  late final User user;

  @override
  void initState() {
    super.initState();
    router = widget._homeRouter;
    user = widget._user;
  }

  @override
  Widget build(BuildContext context) {
    final List<WebUser> activeUserList = context.select(
            (HomeCubit2 cubit) => cubit.state.activeUserList);
    return _buildList(activeUserList);
  }

  _listItem(WebUser user) => ListTile(
    leading: const ProfilePlaceholder(50),
    title: Text(
      user.username,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  _buildList(List<WebUser> users) => ListView.separated(
      padding: const EdgeInsets.only(top: 30.0, right: 16.0),
      itemBuilder: (BuildContext context, indx) => GestureDetector(
        child: _listItem(users[indx]),
        onTap: () => context.read<HomeCubit2>()
            .getChatWith(users[indx].webUserId!)
            .then((chat) => router.onShowMessageThread(context, user, chat)),
      ),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: users.length,
  );


}
