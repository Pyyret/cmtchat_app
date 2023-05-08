import 'package:cmtchat_app/collections/app_collection.dart';
import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';

import 'package:cmtchat_app/views/home/shared_blocs/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/views/shared_widgets/app_bar_kott.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  final IHomeRouter _homeRouter;
  const Home(this._homeRouter, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final IHomeRouter router;

  @override
  void initState() {
    super.initState();
    router = widget._homeRouter;
    _updateChatsOnMessageReceived();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.select((AppCubit cubit) => cubit.state);
    final User user = context.select((AppCubit cubit) => cubit.user);

    // If user is not properly connected, redireck back in AppState
    if (appState is! UserConnectSuccess) {
      context.read<AppCubit>().emit(NoUserConnect());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: const AppBarKott(),
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
                            builder: (context) {
                              final activeUserList = context.select(
                                      (HomeCubit cubit) => cubit.state.activeUserList);
                              return Text('Online (${activeUserList.length})'
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if(state is HomeInitial) {
                        context.read<HomeCubit>().initialize(user: user);
                        WebUser webUser = WebUser.fromUser(user);
                        context.read<WebMessageBloc>().add(WebMessageEvent.onSubscribed(webUser));
                        return const Center( child: CircularProgressIndicator());
                      }
                      return Expanded(
                        child: TabBarView(
                            children: [
                              Chats(user, router),
                              ActiveUsers(user, router),
                            ]),
                      );
                    }),
                ],
            ),


            ),
          ),
    );
  }

  _updateChatsOnMessageReceived() {
    context.read<WebMessageBloc>().stream.listen((state) async {
      if (state is WebMessageReceivedSuccess) {
        await context.read<HomeCubit>().receivedMessage(state.message);
      }
    });
  }
}
