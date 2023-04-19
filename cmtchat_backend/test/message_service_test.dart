import 'package:cmtchat_backend/src/models/message.dart';
import 'package:cmtchat_backend/src/models/user.dart';
import 'package:cmtchat_backend/src/services/encryption/encryption_service_impl.dart';
import 'package:cmtchat_backend/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

Future<void> main() async {
  RethinkDb r = RethinkDb();
  Connection connection = await r.connect(host: '127.0.0.1', port: 28015);
  late MessageService sut;

  setUp(() async {
    final encryption =  EncryptionService(Encrypter(AES(Key.fromLength(32))));
    await createDb(r, connection);
    sut = MessageService(r, connection, encryption);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    'id': '1111',
    'active': true,
    'last_seen': DateTime.now()
  });

  final user2 = User.fromJson({
  'id': '2222',
  'active': true,
  'last_seen': DateTime.now()
  });

  test('Send message', () async {
    Message message = Message(
        from: user1.id,
        to: user2.id,
        timestamp: DateTime.now(),
        contents: 'TESTINGTESTING!'
    );

    final res = await sut.send(message);
    expect(res, true);
  });

  test('Subscribe and receive messages', () async {
    final content = 'TESTINGTESTING!';

    Message message1 = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: content);

    Message message2 = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: content);

    sut.messages(activeUser: user1).listen(expectAsync1((message) {
      expect(message.to, user1.id);
      expect(message.id, isNotEmpty);
      expect(message.contents, content);
    }, count: 2));
    await sut.send(message1);
    await sut.send(message2);
  });

  test('Subscribe and receive new messages when logging on', () async {
    Message message = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: 'TESTINGTESTING!');

    Message message2 = Message(
        from: user2.id,
        to: user1.id,
        timestamp: DateTime.now(),
        contents: 'TESTING AGAIN!');

    /// Sending the messages first
    await sut.send(message);
    await sut.send(message2)

    /// And then subscribing to the stream
        .whenComplete(() =>
        sut.messages(activeUser: user1).listen(expectAsync1((message) {
          expect(message.to, user1.id);
          expect(message.id, isNotEmpty);
    }, count: 2)));
  });
}