import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:cmtchat_app/models/web/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/typing/typing_notification_service_contract.dart';

part 'typing_notification_event.dart';
part 'typing_notification_state.dart';

class TypingNotificationBloc
    extends Bloc<TypingNotificationEvent, TypingNotificationState> {
  final ITypingNotification _typingNotification;
  StreamSubscription? _subscription;

  TypingNotificationBloc(this._typingNotification)
      : super(TypingNotificationState.initial());

  @override
  Stream<TypingNotificationState> mapEventToState(
      TypingNotificationEvent event) async* {
    if (event is Subscribed) {
      if (event.usersWithChat.isEmpty) {
        add(NotSubscribed());
        return;
      }
      await _subscription?.cancel();
      _subscription = _typingNotification
          .subscribe(event.user, event.usersWithChat)
          .listen((typingEvent) => add(_TypingNotificationReceived(typingEvent)));
    }

    if (event is _TypingNotificationReceived) {
      yield TypingNotificationState.received(event.event);
    }

    if (event is TypingNotificationSent) {
      await _typingNotification.send(events: [event.event]);
      yield TypingNotificationState.sent();
    }

    if (event is NotSubscribed) {
      yield TypingNotificationState.initial();
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _typingNotification.dispose();
    return super.close();
  }
}