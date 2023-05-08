import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/viewmodels/user_view_model.dart';

class UserCubit extends Cubit<User> {
  final UserViewModel _viewModel;
  final User _user;
  UserCubit(this._viewModel, this._user) : super(_user);

  void user() { emit(_user); }
}