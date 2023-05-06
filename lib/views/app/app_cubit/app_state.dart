import 'package:cmtchat_app/models/local/user.dart';
import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {}

class AppInitial extends AppState {
  @override
  List<Object> get props => [];
}

class NoUserConnect extends AppState {
  @override
  List<Object> get props => [];
}

class Loading extends AppState {
  @override
  List<Object> get props => [];
}

class UserConnectSuccess extends AppState {
  final User user;
  UserConnectSuccess(this.user);
  @override
  List<Object> get props => [user];
}