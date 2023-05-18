import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


/// User States ///
abstract class UserState extends Equatable {
  final User? user;
  const UserState({this.user});
  @override
  List<Object?> get props => [user];
}

class UserInitial extends UserState { const UserInitial(); }

class UserLoading extends UserState {
  const UserLoading(User? user) : super(user: user); }

class UserLoggedIn extends UserState {
  const UserLoggedIn({required super.user});
}

/// User Cubit ///
class UserCubit extends Cubit<UserState> {
  final Repository _repo;

  UserCubit({required Repository repository})
      : _repo = repository, super(const UserInitial())
  {
    connectUser();
  }

  Future<User?> connectUser() async {
    User? user = await _repo.tryLoginFromCache();
    if(user != null) { emit(UserLoggedIn(user: user)); }
    else { emit(const UserInitial()); }
    return user;
  }

  Future<User> logIn(String username) async {
    emit(UserLoading(state.user));
    final User user = await _repo.logIn(username: username);
    emit(UserLoggedIn(user: user));
    return user;
  }

  Future<void> logOut() async {
    await _repo.logOut();
    emit(const UserInitial());
  }
}