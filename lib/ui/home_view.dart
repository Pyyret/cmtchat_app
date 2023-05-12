import 'package:cmtchat_app/cubit_bloc/home_cubit.dart';
import 'package:cmtchat_app/ui/active_view.dart';
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
              _tabBar(context),
              const Expanded(
                child: TabBarView(
                  children: [
                    Placeholder(),
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

  _tabBar(context) {
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
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if(state is HomeUpdate) {
                    return Text('Online (${state.onlineUsers.length})');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
          ),
        ),

      ],
    );
  }

}