import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/colors.dart';

import 'package:cmtchat_app/views/app/app_cubit/app_cubit.dart';
import 'package:cmtchat_app/views/shared_widgets/logo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarKott extends StatelessWidget with PreferredSizeWidget {
  const AppBarKott({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(170);

  @override
  Widget build(BuildContext context) {
    final String? userName = context.watch<AppCubit>().user.username;
    final bool? status = context.watch<AppCubit>().user.active;

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
                        userName ?? 'noname',
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


  _profileImg(BuildContext context, {required double size}) {
    return SizedBox(
      height: size,
      width: size,
      child: Material(
        color: isLightTheme(context)
            ? const Color(0xFFF2F2F2)
            : const Color(0xFF211E1E),
        borderRadius: BorderRadius.circular(size),
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () {},
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.person_outline_rounded,
              size: size,
              color: isLightTheme(context) ? kIconLight : Colors.black,
            ),
          ),
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
          onTap: () {
            //context.read<HomeCubit2>().changeUserStatus();
          },
        ),
        const SizedBox(width: 15.0),
        Text('Cot', style: Theme.of(context).appBarTheme.titleTextStyle),
      ],
    );
  }
}
