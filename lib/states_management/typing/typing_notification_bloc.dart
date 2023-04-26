import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/web/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/typing/typing_notification_service_contract.dart';
import 'package:equatable/equatable.dart';

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
      TypingNotificationEvent typingEvent) async* {
    if (typingEvent is Subscribed) {
      if (typingEvent.usersWithChat.isEmpty) {
        add(NotSubscribed());
        return;
      }
      await _subscription?.cancel();
      _subscription = _typingNotification
          .subscribe(typingEvent.user, typingEvent.usersWithChat)
          .listen(
              (typingEvent) => add(_TypingNotificationReceived(typingEvent)));
    }

    if (typingEvent is _TypingNotificationReceived) {
      yield TypingNotificationState.received(typingEvent.event);
    }

    if (typingEvent is TypingNotificationSent) {
      await _typingNotification.send(event: typingEvent.event, to: typingEvent.event.to);
      yield TypingNotificationState.sent();
    }

    if (typingEvent is NotSubscribed) {
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