import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';
import 'package:cmtchat_app/repository/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Enum ///
enum HomeStatus { init, loading, ready, failure }

/// State ///
class HomeState extends Equatable {
  final HomeStatus status;
  final List<Chat> chatsList;
  final List<WebUser> activeUserList;

  const HomeState({
    this.status = HomeStatus.init,
    this.chatsList = const <Chat>[],
    this.activeUserList = const <WebUser>[],
  });

  HomeState copyWith({
    HomeStatus Function()? status,
    List<Chat> Function()? chatsList,
    List<WebUser> Function()? activeUserList,
  }) {
    return HomeState(
      status: status != null ? status() : this.status,
      chatsList: chatsList != null ? chatsList() : this.chatsList,
      activeUserList: activeUserList != null ? activeUserList() : this.activeUserList,
    );
  }

  @override
  List<Object> get props => [status, chatsList, activeUserList];
}

/// Events ///
abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubscribeToChatListRequest extends HomeEvent {
  SubscribeToChatListRequest();
}

class ChatClicked extends HomeEvent {
  final Chat chat;
  final BuildContext context;
  ChatClicked({required this.context, required this.chat});
  @override
  List<Object> get props => [chat];
}

/// HomeBloc ///
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final Repository _repository;
  late StreamSubscription <bool> _appStateStream;

  HomeBloc({required Repository repository})
      : _repository = repository, super(const HomeState()) {

    on<SubscribeToChatListRequest>(_onSubscribeToChatListRequest);
    _appStateStream = _repository.loggedIn.listen(
            (loggedIn) {
              if(loggedIn) {
                _onSubscribeToChatListRequest;
              }
            });
  }



  _onSubscribeToChatListRequest(
      SubscribeToChatListRequest event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: () => HomeStatus.loading));

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
  }

}