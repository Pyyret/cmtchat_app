import 'package:cmtchat_app/cubits/web_user_cubit.dart';
import 'package:cmtchat_app/ui/widgets/app_bar_cot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const AppBarCot(),
        body: SafeArea(
          child: Column(
            children: [
              _tabBar(),
              const Expanded(
                child: TabBarView(
                  children: [
                    Placeholder(),
                    Placeholder(),
                    //ActiveUsers(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _tabBar() =>
      TabBar(
        indicatorPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 20,
        ),
        tabs: [
          const Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text('Chats'),
            ),
          ),
          Tab(
            child: Align(
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final WebUserState state = context.watch<WebUserCubit>().state;
                    return state.status == WebUserStatus.updated
                      ? Text('Online (${state.activeUsersList.length})')
                      : const Center(child: CircularProgressIndicator());
                  },
                )
            ),
          ),

        ],
      );
}