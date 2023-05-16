import 'package:cmtchat_app/cubits/home_cubit.dart';
import 'package:cmtchat_app/ui/home/online_tab.dart';
import 'package:cmtchat_app/ui/home/inbox_tab.dart';
import 'package:cmtchat_app/ui/shared_widgets/app_bar_cot.dart';

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
                    InboxTab(),
                    OnlineTab(),
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
