import 'dart:async';
import 'package:cmtchat_app/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';
import 'package:cmtchat_app/ui/router.dart';


/// HomeState ///
class HomeState extends Equatable {
  /// State variables
  final List<Chat> chatsList;
  final List<WebUser> onlineUsers;

  /// Constructors
  const HomeState({required this.chatsList, required this.onlineUsers});
  factory HomeState.initial() => const HomeState(chatsList: [], onlineUsers: []);

  /// Methods
  HomeState copyWith({List<Chat>? chatsList, List<WebUser>? onlineUsers}) {
    return HomeState(
        chatsList: chatsList ?? this.chatsList,
        onlineUsers: onlineUsers ?? this.onlineUsers);
  }

  @override
  List<Object> get props => [chatsList, onlineUsers];
}

/// Home Cubit ///
class HomeCubit extends Cubit<HomeState> {

  /// Data providers
  final Repository _repo;
  final WebUserServiceApi _webUserService;

  /// Router
  final RouterCot _router;

  /// Private variables
  StreamSubscription<List<WebUser>>? _activeUsersSub;
  StreamSubscription<List<Chat>>? _userChatsSub;

  /// Constructor
  HomeCubit({
    required Repository repository,
    required RouterCot router,
    required WebUserServiceApi webUserService })
      : _repo = repository,
        _router = router,
        _webUserService = webUserService,
        super(HomeState.initial())
  {
    // Initializing
    print('HomeCubit created');
    _subscribeToLocalChats();
    _subscribeToOnlineUsers();
  }

  /// Methods ///
  void routeChat(context, Chat chat) => _router.showChat(context, chat);
  void routeChatFromWebUser(context, String webUserId) =>
      _repo.getChat(webUserId).then((chat) => routeChat(context, chat));

  @override
  close() async {
    print('HomeCubit close');
    await _activeUsersSub?.cancel();
    await _webUserService.cancelChangeFeed();
    await _userChatsSub?.cancel();
    super.close();
  }

  /// Private Methods
  _subscribeToLocalChats() async {
    _userChatsSub = _repo
        .allChatsUpdatedStream()
        .listen((chatList) {
          emit(state.copyWith(chatsList: chatList));
          print('chatlist update');
        });
  }

  _subscribeToOnlineUsers() async {
    _activeUsersSub = _webUserService
        .activeUsersStream()
        .listen((onlineUsersList) {
          print('onlineUsersList updated');
          onlineUsersList
              .removeWhere((user) => user.id == _repo.activeUser.webUser.id);
          emit(state.copyWith(onlineUsers: onlineUsersList));
        });
  }
}