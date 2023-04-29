import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:cmtchat_app/states_management/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final IWebUserService _userService;

  HomeCubit(this._userService) : super(HomeInitial());

  Future<WebUser> connect(WebUser webUser) async {
    webUser.lastSeen = DateTime.now();
    webUser.active = true;

    await _userService.connect(webUser);
    return webUser;
  }

  Future<void> activeUsers(WebUser webUser) async {
    emit(HomeLoading());
    final users = await _userService.online();
    users.removeWhere((user) => user.webUserId == webUser.webUserId);
    emit(HomeSuccess(users));
  }
}