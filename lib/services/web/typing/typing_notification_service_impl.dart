import 'dart:async';
import 'package:cmtchat_app/models/web/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'typing_notification_service_contract.dart';

class TypingNotification implements ITypingNotification {
  final Connection _connection;
  final RethinkDb _r;
  final _controller = StreamController<TypingEvent>.broadcast();

  late StreamSubscription _changeFeed;
  final IWebUserService _webUserService;

  /// Constructor
  TypingNotification(this._r, this._connection, this._webUserService);

  /// Methods
  @override
  Future<bool> send({required List<TypingEvent> events}) async {
    final receivers = await _webUserService
        .fetch(events.map((e) => e.to)
        .toList());
    if(receivers.isEmpty) { return false; }
    events
        .retainWhere((event) => receivers.map((e) => e.webUserId)
        .contains(event.to));
    final data = events.map((e) => e.toJson()).toList();
    Map record = await _r
        .table('typing_events')
        .insert(data, {'conflict': 'update'})
        .run(_connection);
    return record['inserted'] >= 1;
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
              .eq(user.webUserId)
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
