import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/states_management/home/home_cubit2.dart';
import 'package:cmtchat_app/states_management/home/home_state2.dart';
import 'package:cmtchat_app/ui/widgets/shared/app_bar_kott.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeUi extends StatefulWidget {
  final User user;
  const HomeUi(this.user, {super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const AppBarKott(),
        body: TabBar(
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
                child: const Align(
                  alignment: Alignment.center,
                  child: Text('Active(0)'),
                  /*
                  BlocBuilder<HomeCubit, HomeState>(
                      builder: (_, state) =>state is HomeSuccess
                          ? Text('Active(${state.onlineUsers.length})')
                          : const Text('Active(0)')

                  ),

                   */


                ),


              ),
            )
          ],
        ),
      ),
    );

  }
}
