import 'dart:async';

import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/web/user/web_user_service_api.dart';

/// Home States ///
abstract class HomeState extends Equatable {}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeUpdate extends HomeState {
  final List<WebUser> onlineUsers;
  HomeUpdate({required this.onlineUsers});

  @override
  List<Object> get props => [onlineUsers];
}


/// Home Cubit ///
class HomeCubit extends Cubit<HomeState> {
  final AppRepository _repo;

  final WebUserServiceApi _webUserService;

  HomeCubit({
    required WebMessageServiceApi messageService,
    required AppRepository repository,
    required WebUserServiceApi webUserService,
  })
      : _messageService = messageService,
        _repo = repository,
        _webUserService = webUserService,
        super(HomeInitial())
  {
    _sub();
    _activeUsersStreamStart();
  }

  final WebMessageServiceApi _messageService;
  StreamSubscription? _subscription;


  _sub() async {
    await _subscription?.cancel();
    await _messageService.cancelChangeFeed();
    _subscription = _messageService
        .messageStream(activeUser: WebUser.fromUser(_repo.user))
        .listen((message) {
          print(message.contents);
    });
  }





  StreamSubscription<List<WebUser>>? _activeUsersSub;

  _activeUsersStreamStart() async {
    await _activeUsersSub?.cancel();
    await _webUserService.cancelChangeFeed();
    print('init');
    _activeUsersSub = _webUserService
        .activeUsersStream()
        .listen((list) => print('sssss'));



  }

  dispose() async {
    print('dispose');
    await _activeUsersSub?.cancel();
    await _webUserService.dispose();
    return super.close();
  }
}