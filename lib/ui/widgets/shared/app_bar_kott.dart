import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/states_management/home/home_cubit2.dart';
import 'package:cmtchat_app/states_management/home/home_state2.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/ui/widgets/shared/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarKott extends StatelessWidget with PreferredSizeWidget {
  const AppBarKott({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(170);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<HomeCubit2, HomeState2>(
        builder: (context, state) => _buildAppBar(context, state.user));
  }

  _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      backgroundColor: Colors.blueGrey,
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
                      user?.username ?? 'noname',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 30.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.active ?? false ? 'online' : 'offline',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 20),
                    ),
                  ],
                )),
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
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 50)),
        const SizedBox(width: 15.0),
        GestureDetector(
          child: const Logo(),
          onTap: () {
            print('tap');
            context.read<HomeCubit2>().changeUserStatus();
          },
        ),
        const SizedBox(width: 15.0),
        Text('Cot',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 50)),
      ],
    );
  }
}
