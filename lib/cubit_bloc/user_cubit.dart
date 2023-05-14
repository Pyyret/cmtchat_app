import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/user_webuser_service_collection.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
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
  final AppRepository _repo;

  UserCubit({required AppRepository repository})
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

  Future<User?> newUserLogin(String username) async {
    emit(UserLoading(state.user));
    final User? user = await _repo.newUserLogin(username);
    user == null
        ? emit(const UserInitial())
        : emit(UserLoggedIn(user: user));
    return user;
  }

  Future<void> logOut() async {
    await _repo.logOut();
    emit(const UserInitial());
  }
}