import 'package:cmtchat_app/cubits/home_cubit.dart';
import 'package:cmtchat_app/ui/home/online_tab.dart';
import 'package:cmtchat_app/ui/home/inbox_tab.dart';
import 'package:cmtchat_app/ui/router.dart';
import 'package:cmtchat_app/ui/shared_widgets/app_bar_cot.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({required this.router, super.key});

  final RouterCot router;

  @override
  Widget build(BuildContext context) {
    print('HomeView build');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const AppBarCot(),
        body: SafeArea(
          child: Column(
            children: [
              _tabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    InboxTab(router: router),
                    OnlineTab(router: router,),
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
