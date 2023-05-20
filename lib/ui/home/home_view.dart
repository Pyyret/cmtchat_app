import 'package:cmtchat_app/cubits/home_cubit.dart';
import 'package:cmtchat_app/ui/home/online_tab.dart';
import 'package:cmtchat_app/ui/home/inbox_tab.dart';
import 'package:cmtchat_app/ui/router.dart';
import 'package:cmtchat_app/ui/home/cot_app_bar.dart';

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
        appBar: const CotAppBar(),
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
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                final nrOfUnreadMsg = context
                    .select((HomeCubit c) => c.state.chatsList
                    .where((chat) => chat.unread > 0)
                    .length,
                );
                if(nrOfUnreadMsg == 0) { return const Text('Chats'); }
                else { return Text('Chats ($nrOfUnreadMsg)'); }
                }
              ),
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
