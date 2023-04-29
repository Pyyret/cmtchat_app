import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/states_management/home/chats_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_state.dart';
import 'package:cmtchat_app/states_management/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/ui/widgets/home/active/active_users.dart';
import 'package:cmtchat_app/ui/widgets/home/chats/chats.dart';
import 'package:cmtchat_app/ui/widgets/shared/profile_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    context.read<ChatsCubit>().chats();
    context.read<HomeCubit>().activeUsers();

    WebUser mainUser = context.read<ChatsCubit>().viewModel.getMainWebUser();
    context.read<WebMessageBloc>().add(WebMessageEvent.onSubscribed(mainUser));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Container(
              width: double.maxFinite,
              child: Row(
                children: [
                  ProfilePlaceholder(50),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'name',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'online',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            bottom: TabBar(
              indicatorPadding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              tabs: [
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text('Messages'),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: BlocBuilder<HomeCubit, HomeState>(
                          builder: (_, state) =>state is HomeSuccess
                              ? Text('Active(${state.onlineUsers.length})')
                              : const Text('Active(0)')
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Chats(),
              ActiveUsers(),
            ],
          ),
        ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
