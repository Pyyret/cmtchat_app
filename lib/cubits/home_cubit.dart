import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cmtchat_app/repository.dart';
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

  final IRouter _router;

  /// Stream subscriptions

  StreamSubscription<List<WebUser>>? _activeUsersSub;
  StreamSubscription<List<Chat>>? _userChatsSub;

  /// Constructor
  HomeCubit({
    required Repository repository,
    required IRouter router,
    required WebUserServiceApi webUserService,
  })
      : _repo = repository,
        _router = router,
        _webUserService = webUserService,
        super(HomeState.initial())
  {
    // Initializing
    _subscribeToLocalChats();
    _subscribeToOnlineUsers();
  }


  /// Methods ///
  void routeChatFromWebUser(WebUser webUser) =>
      _repo.getChat(webUser).then((chat) => routeChat(chat));
  void routeChat(Chat chat) => _router.showChat(chat);


  /// Local Methods ///
  _subscribeToLocalChats() async {
    await _userChatsSub?.cancel();
    _userChatsSub = _repo.allChatsUpdatedStream()
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
        .listen((onlineUsersList) {
          onlineUsersList.removeWhere(
                  (user) => user.id == _repo.userWebId);
          emit(state.copyWith(onlineUsers: onlineUsersList));
        });
  }

  _close() async {
    await _activeUsersSub?.cancel();
    await _webUserService.dispose();
    return super.close();
  }
}