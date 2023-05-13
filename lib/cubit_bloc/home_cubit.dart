import 'dart:async';

import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/web/user/web_user_service_api.dart';

/// Home States ///
class HomeState extends Equatable {
  const HomeState({required this.chatsList, required this.onlineUsers});

  final List<Chat> chatsList;
  final List<WebUser> onlineUsers;

  HomeState copyWith({List<Chat>? chatsList, List<WebUser>? onlineUsers}) {
    return HomeState(
        chatsList: chatsList ?? this.chatsList,
        onlineUsers: onlineUsers ?? this.onlineUsers);
  }

  factory HomeState.initial() => const HomeState(chatsList: [], onlineUsers: []);

  @override
  List<Object> get props => [chatsList, onlineUsers];
}

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
        super(HomeState.initial())
  {
    // Initializing
    _subscribeToLocalChats();
    //_subscribeToWebMessages();
    _subscribeToOnlineUsers();
  }

  /// Data providers
  final AppRepository _repo;
  final WebUserServiceApi _webUserService;
  final WebMessageServiceApi _messageService;


  /// Stream subscriptions ///
  StreamSubscription<WebMessage>? _webMessageSub;
  StreamSubscription<List<WebUser>>? _activeUsersSub;
  StreamSubscription<List<Chat>>? _userChatsSub;


  /// Methods ///

  /// Local Methods ///
  _subscribeToLocalChats() async {
    await _userChatsSub?.cancel();
    final userChatStream = await _repo.allChatsUpdatedStream();
    _userChatsSub = userChatStream
        .listen((chatList) {
          emit(state.copyWith(chatsList: chatList));
          print('chatlist update');
    });
  }

  _subscribeToOnlineUsers() async {
    await _activeUsersSub?.cancel();
    await _webUserService.cancelChangeFeed();
    _activeUsersSub = _webUserService
        .activeUsersStream()
        .listen((list) {
          emit(state.copyWith(onlineUsers: list));
          print('onlineUsersUpdate');
          print(list.length);
        });
  }

  _subscribeToWebMessages() async {
    await _webMessageSub?.cancel();
    await _messageService.cancelChangeFeed();
    _webMessageSub = _messageService
        .messageStream(activeUser: WebUser.fromUser(_repo.user))
        .listen((message) {
      print(message.contents); });
  }

  _dispose() async {
    print('dispose');
    await _activeUsersSub?.cancel();
    await _webUserService.dispose();
    return super.close();
  }
}