import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:equatable/equatable.dart';

import '../models/web/web_user.dart';


/// WebUserStatus enum ///
enum WebUserStatus { loading, updated }

/// State ///
class WebUserState extends Equatable {
  final WebUserStatus status;
  final List<WebUser> activeUsersList;

  const WebUserState({
    this.status = WebUserStatus.loading,
    this.activeUsersList = const <WebUser>[],
  });

  WebUserState copyWith({
    WebUserStatus? status,
    List<WebUser>? activeUsersList,
}) {
    return WebUserState(
        status: status ?? this.status,
        activeUsersList: activeUsersList ?? this.activeUsersList
    );
  }

  @override
  List<Object?> get props => [status, activeUsersList];

  /// State Factories ///
  init() => const WebUserState();
  loading() => copyWith(status: WebUserStatus.loading);
  updated({required List<WebUser> webUserList}) => copyWith(
      status: WebUserStatus.updated,
      activeUsersList: webUserList);
}

/// NavCubit ///
class WebUserCubit extends Cubit<WebUserState> {
  final AppRepository _repo;
  StreamSubscription? _subscription;

  WebUserCubit({required AppRepository repository})
      : _repo = repository, super(const WebUserState())
  {
    _repo.loggedIn.listen((loggedIn) {
      if(loggedIn) {
        _initializeStream();
      }
      else {
        emit(state.loading());
        emit(state.init());
      }
    });
  }

  _newListReceived(activeUsersList) {

    emit(state.loading());
    activeUsersList.removeWhere(
            (WebUser webUser) => webUser.webUserId == _repo.user.webUserId,
    );
    emit(state.updated(webUserList: activeUsersList));
  }

  _initializeStream() async {
    print('test');
    await _subscription?.cancel();
    _subscription = _repo.webUserService
        .subscribe()
        .listen((activeUsersList) => _newListReceived(activeUsersList),
    );
  }

  @override
  Future<void> close() {
    emit(state.loading());
    _subscription?.cancel();
    _repo.webUserService.dispose();
    emit(state.init());
    return super.close();
  }

}
