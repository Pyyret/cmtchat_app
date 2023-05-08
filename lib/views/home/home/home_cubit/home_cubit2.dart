import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/viewmodels/home_view_model.dart';

import '../../../../collections/user_webuser_service_collection.dart';
import 'home_state2.dart';

class HomeCubit2 extends Cubit<HomeState2> {
  final HomeViewModel _homeViewModel;

  HomeCubit2(this._homeViewModel) : super(HomeInit());

  void initialize({required User user}) {
    _homeViewModel.setUser(user);
    update();
  }

  Future<Chat> getChatWith(String webUserId) async {
    final chat = await _homeViewModel.getChatWith(webUserId);
    update();
    return chat;
  }


  Future<void> receivedMessage(WebMessage webMessage) async {
    await _homeViewModel.receivedMessage(webMessage);
    await update();
  }

  Future<void> update() async {
    emit(LoadingHome());
    List<Chat> chatList = await _homeViewModel.getChats();
    List<WebUser> activeUserList = await _homeViewModel.activeUsers();
    emit(SyncedHome(chatList, activeUserList));
  }

  /*
  void user() { emit(HomeUser(_user)); }

  void changeUserStatus() {
    if(state is UserUpdated) { super.emit(HomeInit()); }
    _user.active = !_user.active!;
    print(_user.active);
    emit(UserUpdated(_user));
  }

   */

}