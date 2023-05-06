import 'package:cmtchat_app/collections/chats_collection.dart';
import 'package:cmtchat_app/collections/home_cubit_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';

import 'package:cmtchat_app/views/home/active_users/active_users.dart';

import 'package:cmtchat_app/views/home/home/home_router.dart';
import 'package:cmtchat_app/views/home/shared_blocs/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/views/shared_widgets/header_status_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  final User mainUser;
  final IHomeRouter router;

  const Home(this.mainUser, this.router, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late final User _mainUser;

  @override
  void initState() {
    super.initState();
    _mainUser = widget.mainUser;
    final mainWebUser = WebUser.fromUser(_mainUser);
    _updateChatsOnMessageReceived();

    context.read<ChatsCubit>().chats();
    context.read<HomeCubit>().activeUsers(mainWebUser);
    context.read<WebMessageBloc>().add(WebMessageEvent.onSubscribed(mainWebUser));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: HeaderStatus(
                _mainUser.username ?? '',
                _mainUser.photoUrl ?? '',
                _mainUser.active ?? true,
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
          body: TabBarView(
            children: [
              Chats(_mainUser, widget.router),
              ActiveUsers(_mainUser, widget.router),
            ],
          ),
        ),
    );
  }

  _updateChatsOnMessageReceived() {
    final chatsCubit = context.read<ChatsCubit>();
    context.read<WebMessageBloc>().stream.listen((state) async {
      if(state is WebMessageReceivedSuccess) {
        await chatsCubit.viewModel.receivedMessage(state.message);
        await chatsCubit.chats();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
