import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/cubit_bloc/user_cubit.dart';
import 'package:cmtchat_app/cubits/navigation_cubit.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/ui/widgets/logo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarCot extends StatelessWidget with PreferredSizeWidget {
  const AppBarCot({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(170);

  @override
  Widget build(BuildContext context) {
    String? username = context.select(
            (UserCubit cubit) => cubit.state.user?.username);
    bool? status = context.select((UserCubit cubit) => cubit.state.user?.active);

    return AppBar(
      flexibleSpace: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: _logo(context),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10.0),
              child: Column(
                children: [
                  Text(
                      username ?? 'noname',
                      style: Theme.of(context).appBarTheme.toolbarTextStyle
                  ),
                  Text(
                    status ?? false ? 'online' : 'offline',
                    style: Theme.of(context).appBarTheme.toolbarTextStyle
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.w100),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  _logo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Chat',
            style: Theme.of(context).appBarTheme.titleTextStyle),
        const SizedBox(width: 15.0),
        GestureDetector(
          child: const Logo(),
          onTap: () { context.read<UserCubit>().logOut(); },
        ),
        const SizedBox(width: 15.0),
        Text('Cot', style: Theme.of(context).appBarTheme.titleTextStyle),
      ],
    );
  }
}
