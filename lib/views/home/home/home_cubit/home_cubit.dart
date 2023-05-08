import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/viewmodels/home_view_model.dart';

import '../../../../collections/user_webuser_service_collection.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeViewModel _homeViewModel;

  HomeCubit(this._homeViewModel) : super(HomeInitial());

  void initialize({required User user}) {
    _homeViewModel.setUser(user);
    update();
  }

  Future<Chat> getChatWith(String webUserId) async {
    final chat = await _homeViewModel.getChatWith(webUserId);
    update();
    return chat!;
  }


  Future<void> receivedMessage(WebMessage webMessage) async {
    await _homeViewModel.receivedMessage(webMessage);
    await update();
  }

  Future<void> update() async {
    emit(HomeLoading());
    List<Chat> chatList = await _homeViewModel.getChats();
    List<WebUser> activeUserList = await _homeViewModel.activeUsers();
    emit(HomeSynced(chatList, activeUserList));
  }
}