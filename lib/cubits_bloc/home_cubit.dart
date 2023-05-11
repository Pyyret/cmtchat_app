import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';
import 'package:cmtchat_app/repository/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// State ///
abstract class HomeState extends Equatable {
  final List<Chat> chatsList;
  const HomeState(this.chatsList,);

  @override
  List<Object> get props => [chatsList];
}

class Initial extends HomeState {
  const Initial(super.chatsList);
}

class Started extends HomeState {
  const Started(super.chatsList,);
}

/// Events ///
abstract class HomeEvent {
  const HomeEvent();
}

class UserLoggedIn extends HomeEvent {
  UserLoggedIn();
}

/// HomeBloc ///
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final Repository _repository;
  static const List<Chat> chatsList = [];

  StreamSubscription<bool>? _appStateStream;


  HomeBloc({required Repository repository})
      : _repository = repository, super(Initial(chatsList)) {
    print('hello');
    print(state);
    on<UserLoggedIn>(_userLoggedIn);
  }


  _userLoggedIn(
      UserLoggedIn event, Emitter<HomeState> emit) async {
    emit(Started(chatsList));

    /*
    //_appStateStream?.cancel();
    await emit.forEach<List<Chat>>(
      await _repository.getAllChatsStreamUpdated,
      onData: (chatsList) =>
          state.copyWith(
            status: () => HomeStatus.ready,
            chatsList: () => chatsList,
          ),
      onError: (_, __) =>
          state.copyWith(
            status: () => HomeStatus.failure,
          ),
    );

     */
  }

}
