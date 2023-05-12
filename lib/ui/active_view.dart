import 'package:cmtchat_app/cubit_bloc/home_cubit.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../views/shared_widgets/profile_placeholder.dart';

class ActiveView extends StatelessWidget {
  const ActiveView({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if(state is HomeUpdate) {
          return _buildList(context, state.onlineUsers); }
        else { return const Center(child: CircularProgressIndicator()); }
         }
    );
  }

  _buildList(context, List<WebUser> users) => ListView.separated(
    padding: const EdgeInsets.only(top: 30.0, right: 16.0),
    itemBuilder: (_, indx) => GestureDetector(
      child: _listItem(context, users[indx]),
      onTap: () async {
        print('tap');
      },
    ),
    separatorBuilder: (_, __) => const Divider(),
    itemCount: users.length,
  );


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

