import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:equatable/equatable.dart';

/// Home States ///
abstract class HomeState extends Equatable {
  const HomeState({this.activeUsersList});
  final List<WebUser>? activeUsersList;

  @override
  List<Object?> get props => [activeUsersList]; }

class HomeInitial extends HomeState {
  const HomeInitial(); }

class HomeLoading extends HomeState {
  const HomeLoading(List<WebUser>? list) : super(activeUsersList: list); }

class HomeUpdate extends HomeState {
  const HomeUpdate({required super.activeUsersList});}


/// Home Cubit ///
class HomeCubit extends Cubit<HomeState> {
  final AppRepository _repo;
  StreamSubscription<List<WebUser>>? _activeUsersSub;

  HomeCubit({required AppRepository repository})
      : _repo = repository, super(const HomeInitial())
  {
    _initializeStreams();
  }

  _initializeStreams() {
    emit(HomeLoading(state.activeUsersList));
    _activeUsersStreamStart();
  }


  updatedList(list) {
    print(list);
    emit(HomeUpdate(activeUsersList: list));
  }

  _activeUsersStreamStart() async {
    _activeUsersSub = _repo
        .webUserService
        .activeUsersStream()
        .listen((list) async => updatedList(list));
  }



  dispose() async {
    _activeUsersSub?.cancel();
  }
}