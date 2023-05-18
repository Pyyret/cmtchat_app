import 'package:cmtchat_app/cubits/root_cubit.dart';
import 'package:cmtchat_app/ui/shared_widgets/logo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarCot extends StatelessWidget with PreferredSizeWidget {
  const AppBarCot({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(170);

  @override
  Widget build(BuildContext context) {
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
                  Text(context.select(
                          (RootCubit cubit) => cubit.state.user.username),
                      style: Theme.of(context).appBarTheme.toolbarTextStyle
                  ),
                  Text(context.select((RootCubit cubit) => cubit
                      .state.user.active) ? 'online' : 'offline',
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
        Text('Chat', style: Theme.of(context).appBarTheme.titleTextStyle),
        const SizedBox(width: 15.0),
        GestureDetector(
          child: const Logo(),
          onTap: () { context.read<RootCubit>().logOut(); },
        ),
        const SizedBox(width: 15.0),
        Text('Cot', style: Theme.of(context).appBarTheme.titleTextStyle),
      ],
    );
  }
}
