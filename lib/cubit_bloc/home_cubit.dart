import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:equatable/equatable.dart';

/// Home States ///
abstract class HomeState extends Equatable {
  const HomeState({required this.activeUsersList});
  final List<WebUser> activeUsersList;

  @override
  List<Object> get props => [activeUsersList]; }

class HomeInitial extends HomeState {
  const HomeInitial({required super.activeUsersList}); }

class HomeLoading extends HomeState {
  const HomeLoading(List<WebUser> list) : super(activeUsersList: list); }

class HomeUpdate extends HomeState {
  const HomeUpdate({required super.activeUsersList});}


/// Home Cubit ///
class HomeCubit extends Cubit<HomeState> {
  final AppRepository _repo;
  StreamSubscription<List<WebUser>>? _activeUsersSub;

  HomeCubit({required AppRepository repository})
      : _repo = repository, super(const HomeInitial(activeUsersList: []))
  {
    emit(const HomeUpdate(activeUsersList: []));
  }




  dispose() async {
    await _activeUsersSub?.cancel();
  }
}