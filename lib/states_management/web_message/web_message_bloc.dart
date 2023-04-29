import 'dart:async';

import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_contract.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'web_message_event.dart';
part 'web_message_state.dart';

class WebMessageBloc extends Bloc<WebMessageEvent, WebMessageState> {

  final IWebMessageService _messageService;
  StreamSubscription? _subscription;

  WebMessageBloc(this._messageService) : super(WebMessageState.initial());

  @override
  Stream<WebMessageState> mapEventToState(WebMessageEvent event) async* {
    if(event is Subscribed) {
      await _subscription?.cancel();
      _subscription = _messageService
          .messageStream(activeUser: event.user)
          .listen((message) => add(_WebMessageReceived(message)));
    }

    if(event is _WebMessageReceived) {
      yield WebMessageState.received(event.message);
    }

    if(event is WebMessageSent) {
      final webMessage = await _messageService.send(message: event.message);
      yield WebMessageState.sent(webMessage);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _messageService.dispose();
    return super.close();
  }
}