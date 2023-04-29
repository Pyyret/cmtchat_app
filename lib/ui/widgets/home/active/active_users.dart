import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/states_management/home/home_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_state.dart';
import 'package:cmtchat_app/ui/widgets/shared/profile_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveUsers extends StatefulWidget {
  const ActiveUsers();

  @override
  State<ActiveUsers> createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
        builder: (_, state) {
          if(state is HomeLoading) {
            return Center( child: CircularProgressIndicator());
          }
          if(state is HomeSuccess) {
            return _buildList(state.onlineUsers);
          }
          return Container();
        });
  }

  _listItem(WebUser user) => ListTile(
    leading: ProfilePlaceholder(50),
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
      itemBuilder: (BuildContext context, indx) => _listItem(users[indx]),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: users.length,
  );

}
