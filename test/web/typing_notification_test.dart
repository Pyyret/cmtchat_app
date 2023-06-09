import 'package:cmtchat_app/_deprecated/models/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/typing/typing_notification_service_impl.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';
import 'package:cmtchat_app/services/web/user/web_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';


void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late TypingNotification sut;
  late WebUserServiceApi webUserService;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    webUserService = WebUserService(r, connection);
    sut = TypingNotification(r, connection, webUserService);
  });
  
  tearDown(() async {
    await cleanDb(r, connection);
  });

  final user1 = WebUser.fromJson({
    'id': '1111',
    'username': '1111',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
  });

  final user2 = WebUser.fromJson({
    'id': '2222',
    'username': '2222',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
  });
  
  test('Send typing notification', () async {
    await webUserService.connect(user2);
    TypingEvent typingEvent = TypingEvent(
        from: user1.id!,
        to: user2.id!,
        event: Typing.start
    );
    final res = await sut.send(events: [typingEvent]);

    expect(res, true);
  });

  test('Subscribe and receive typing events', () async {
    await webUserService.connect(user1);
    await webUserService.connect(user2);

    sut.subscribe(user2, [user1.id!])
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

    await sut.send(events: [typing]);
    await sut.send(events: [stopTyping]);
  });
}