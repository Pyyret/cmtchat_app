import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/local/user.dart';

class MainUserCubit extends Cubit<User> {
  final User user;
  MainUserCubit(this.user) : super(user);

  User mainUser() => user;
}