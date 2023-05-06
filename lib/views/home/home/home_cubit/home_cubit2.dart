import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/viewmodels/home_view_model.dart';

import 'home_state2.dart';

class HomeCubit2 extends Cubit<HomeState2> {
  final HomeViewModel _homeViewModel;
  final User _user;

  HomeCubit2(this._user, this._homeViewModel) : super(HomeInit());


  void user() { emit(HomeUser(_user)); }

  void changeUserStatus() {
    if(state is UserUpdated) { super.emit(HomeInit()); }
    _user.active = !_user.active!;
    print(_user.active);
    emit(UserUpdated(_user));
  }

}