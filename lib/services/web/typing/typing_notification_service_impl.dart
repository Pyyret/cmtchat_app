import 'dart:async';
import 'package:cmtchat_app/models/web/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'typing_notification_service_contract.dart';

class TypingNotification implements ITypingNotification {
  final Connection _connection;
  final RethinkDb _r;
  final _controller = StreamController<TypingEvent>.broadcast();

  late StreamSubscription _changeFeed;

  /// Constructor
  TypingNotification(this._r, this._connection);

  /// Methods
  @override
  Future<bool> send({required TypingEvent event, required WebUser to}) async {
    if(!to.active) return false;
    Map record = await _r
        .table('typing_events')
        .insert(event.toJson(), {'conflict': 'update'})
        .run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(WebUser user, List<String> userIds) {
    _startReceivingTypingEvents(user, userIds);
    return _controller.stream;
  }

  @override
  void dispose() {
    _changeFeed.cancel();
    _controller.close();
  }

  _startReceivingTypingEvents(WebUser user, List<String> userIds) {
    _changeFeed = _r
        .table('typing_events')
        .filter((event) {
          return event('to')
              .eq(user.webId)
              .and(_r.expr(userIds).contains(event('from')));
        })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if(feedData['new_val'] == null) return;
            final typingEvent = _eventFromFeed(feedData);
            _controller.sink.add(typingEvent);
            _removeEvent(typingEvent);
          })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  TypingEvent _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  _removeEvent(TypingEvent event) {
    _r
        .table('typing_events')
        .get(event.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
