import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:equatable/equatable.dart';

import '../repository/app_repository.dart';

/// NavStatus enum ///
enum NavStatus { noUser, loading, loggedIn }

/// State ///
class NavState extends Equatable {
  final NavStatus status;
  final User? user;

  const NavState({
    this.status = NavStatus.noUser,
    this.user,
  });

  NavState copyWith({
    NavStatus? status,
    User? user,
}) {
    return NavState(
        status: status ?? this.status,
        user: user ?? this.user
    );
  }

  @override
  List<Object?> get props => [status, user];

  /// State factories ///
  noUser() => copyWith(user: User.empty(), status: NavStatus.noUser);
  loading() => copyWith(status: NavStatus.loading);
  logIn({required User user}) => copyWith(user: user, status: NavStatus.loggedIn);
  userUpdate({required User user}) => copyWith(status: NavStatus.loggedIn, user: user);
}

/// NavCubit ///
class NavCubit extends Cubit<NavState> {
  final AppRepository _repo;

  NavCubit({required AppRepository repository})
      : _repo = repository, super(const NavState().noUser())
  {
    _listenForUserChanges();
  }


  _userUpdate() {
    emit(state.loading());
    emit(state.userUpdate(user: _repo.user));
    print('update');
  }

  _listenForUserChanges() {
    _repo.loggedIn.listen((bool loggedIn) {
      if(loggedIn && state.status == NavStatus.loggedIn) { _userUpdate(); }
      else if(loggedIn) { emit(state.logIn(user: _repo.user)); }
      else { emit(state.noUser()); }
    });

  }

}
