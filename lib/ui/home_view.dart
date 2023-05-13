import 'package:cmtchat_app/cubit_bloc/home_cubit.dart';
import 'package:cmtchat_app/ui/active_view.dart';
import 'package:cmtchat_app/ui/inbox_view.dart';
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
                    InboxView(),
                    ActiveView(),
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

  _tabBar() {
    return TabBar(
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
                child: Builder(builder: (context) {
                  final int nrOfOnlineUsers = context.select(
                          (HomeCubit c) => c.state.onlineUsers.length);
                  return Text('Online ($nrOfOnlineUsers)');
                  }),
              ),
          )
        ]
    );
  }
}
