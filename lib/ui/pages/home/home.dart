import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/states_management/home/chats_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_cubit.dart';
import 'package:cmtchat_app/states_management/home/home_state.dart';
import 'package:cmtchat_app/states_management/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/ui/pages/home/home_router.dart';
import 'package:cmtchat_app/ui/widgets/home/active/active_users.dart';
import 'package:cmtchat_app/ui/widgets/home/chats/chats.dart';
import 'package:cmtchat_app/ui/widgets/shared/header_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  final User mainUser;
  final IHomeRouter router;

  const Home(this.mainUser, this.router);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late User _mainUser;

  @override
  void initState() {
    super.initState();
    _mainUser = widget.mainUser;
    _initialSetup();
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

  _initialSetup() async {

    final mainWebUser = await context.read<ChatsCubit>().viewModel.makeSureConnected();

    context.read<ChatsCubit>().chats();
    context.read<HomeCubit>().activeUsers(mainWebUser);
    context.read<WebMessageBloc>().add(WebMessageEvent.onSubscribed(mainWebUser));
  }

  @override
  bool get wantKeepAlive => true;
}
