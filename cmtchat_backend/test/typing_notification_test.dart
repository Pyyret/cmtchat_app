import 'package:cmtchat_backend/src/models/typing_event.dart';
import 'package:cmtchat_backend/src/models/user.dart';
import 'package:cmtchat_backend/src/services/typing/typing_notification_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late TypingNotification sut;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    sut = TypingNotification(r, connection);
  });
  
  tearDown(() async {
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    'id': '1111',
    'username': '1111',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
  });

  final user2 = User.fromJson({
    'id': '2222',
    'username': '2222',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
  });
  
  test('Send typing notification', () async {
    TypingEvent typingEvent = TypingEvent(
        from: user1.id!,
        to: user2.id!,
        event: Typing.start
    );
    final res = await sut.send(event: typingEvent, to: user2);

    expect(res, true);
  });

  test('Subscribe and receive typing events', () async {
    sut
        .subscribe(user2, [user1.id!])
        .listen(expectAsync1((event) {
          expect(event.from, user1.id);
    }, count: 2));

    TypingEvent typing = TypingEvent(
        from: user1.id!,
        to: user2.id!,
        event: Typing.start
    );

    TypingEvent stopTyping = TypingEvent(
        from: user1.id!,
        to: user2.id!,
        event: Typing.stop
    );

    await sut.send(event: typing, to: user2);
    await sut.send(event: stopTyping, to: user2);
  });
}