import 'package:cmtchat_app/models/local/user.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {}

class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class NoUser extends UserState {
  @override
  List<Object> get props => [];
}

class Loading extends UserState {
  @override
  List<Object> get props => [];
}

class UserConnectSuccess extends UserState {
  final User user;
  UserConnectSuccess(this.user);
  @override
  List<Object> get props => [user];
}