/*

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cmtchat_app/collections/services.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/repository.dart';

class MessageState extends Equatable {
  /// State variables
  final List<WebMessage> list;
  final int nr;
  /// Constructors
  const MessageState({required this.list, required this.nr});

  @override
  List<Object> get props => [list, nr];
}


/// Home Cubit ///
class MessageCubit extends Cubit<MessageState> {

  /// Data providers
  final Repository _repo;
  final WebMessageServiceApi _webMessageService;


  /// Private variables
  StreamSubscription<WebMessage>? _webMessageSub;

  /// Constructor
  MessageCubit({
    required Repository repository,
    required WebMessageServiceApi webMessageService })
      : _repo = repository,
        _webMessageService = webMessageService,
        super(const MessageState(list: [], nr: 1))
  {
    // Initializing
    print('MessageCubit created');
    _subscribeToWebMessages();
  }

  /// Methods ///

  @override
  close() async {
    print('MessageCubit close');
    await _webMessageSub?.cancel();
    await _webMessageService.cancelChangeFeed();
    super.close();
  }

  /// Private Methods
  _subscribeToWebMessages() {
    emit(MessageState(list: [], nr: state.nr+1));
    _webMessageSub = _webMessageService.messageStream(webUserId: _repo.activeUser.webId)
        .listen((msg) {
          _repo.receivedMessage(msg);
          emit(MessageState(list: [msg], nr: state.nr+1));
    });
  }
}

 */