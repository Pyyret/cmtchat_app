import 'dart:async';

import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/local/user.dart';
import '../services/web/user/web_user_service_api.dart';

/// Home States ///
abstract class HomeState extends Equatable {
  HomeState();
  final List<User> chatsList =  <User>[];
  final List<WebUser> onlineUsers = <WebUser>[];

  @override
  List<Object> get props => [chatsList, onlineUsers];
}

class HomeInitial extends HomeState { HomeInitial(); }
class HomeLoading extends HomeState { }
class HomeUpdate extends HomeState {
  HomeUpdate.copyWith({List<User>? chatsList, List<WebUser>? onlineUsers})
      : chatsList = chatsList ?? this.chatsList }


/// Home Cubit ///
class HomeCubit extends Cubit<HomeState> {

  /// Constructor
  HomeCubit({
    required AppRepository repository,
    required WebMessageServiceApi messageService,
    required WebUserServiceApi webUserService,
  })
      : _repo = repository,
        _webUserService = webUserService,
        _messageService = messageService,
        super(HomeInitial())
  {
    // Initializing
    _webMessageSubscribe();
    _onlineUsersSubscribe();
    emit(HomeUpdate());
  }

  /// Data providers
  final AppRepository _repo;
  final WebUserServiceApi _webUserService;
  final WebMessageServiceApi _messageService;



  /// Streams  ///


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

  StreamSubscription<WebMessage> _webMessageSub;
  StreamSubscription<List<WebUser>> _activeUsersSub;
  StreamSubscription<List<Chat>> _userChatsSub;

  _localChatsSubscribe() async {
    final _userChatStream = await _repo.allChatsUpdatedStream();
    _userChatsSub = _userChatStream
        .listen((chatList) => this.state.chatsList = chatList
        emit(HomeUpdate(chat))
    )
  }

  _webMessageSubscribe() async {
    await _webMessageSub.cancel();
    await _messageService.cancelChangeFeed();
    _webMessageSub = _messageService
        .messageStream(activeUser: WebUser.fromUser(_repo.user))
        .listen((message) {
          print(message.contents); });
  }

  _onlineUsersSubscribe() async {
    await _activeUsersSub.cancel();
    await _webUserService.cancelChangeFeed();
    print('init');
    _activeUsersSub = _webUserService
        .activeUsersStream().listen((list) => print('sssss'));
  }

  dispose() async {
    print('dispose');
    await _activeUsersSub?.cancel();
    await _webUserService.dispose();
    return super.close();
  }
}