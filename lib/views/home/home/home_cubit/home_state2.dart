import 'package:cmtchat_app/models/local/user.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState2 extends Equatable {
  User? get user;
}

class HomeInit extends HomeState2 {
  @override
  List<Object> get props => [];

  @override
  User? get user => null;
}

class HomeUser extends HomeState2 {
  @override
  final User user;
  HomeUser(this.user);
  @override
  List<Object> get props => [user];
}

class UserUpdated extends HomeState2 {
  @override
  final User user;
  UserUpdated(this.user);
  @override
  List<Object> get props => [user];

}