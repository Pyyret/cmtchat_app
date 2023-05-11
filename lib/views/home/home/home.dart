import 'package:cmtchat_app/collections/home_collection.dart';

import 'package:cmtchat_app/views/home/home/home_cubit/home_bloc.dart';
import 'package:cmtchat_app/views/shared_widgets/app_bar_kott.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: const AppBarCott(),
          body: SafeArea(
            child: Column(
                children: [
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
                            builder: ( context) {
                              //final int activeUsers = context.select(
                                //      (HomeBloc b) => b.state.activeUsers);
                              return //status == Status.ready
                                  //? Text('Online (${activeUsers})')
                                   const Center(child: CircularProgressIndicator());
                            },
                          )
                          ),
                        ),

                    ],
                  ),
                  const Expanded(
                      child: TabBarView(
                          children: [
                            Chats(),
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
}