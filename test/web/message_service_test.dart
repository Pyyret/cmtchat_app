import 'package:cmtchat_app/models/local/messages.dart';
import 'package:cmtchat_app/models/local/users.dart';
import 'package:cmtchat_app/services/web/encryption/encryption_service_impl.dart';
import 'package:cmtchat_app/services/web/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

Future<void> main() async {
  RethinkDb r = RethinkDb();
  final Connection connection = await r.connect(host: '127.0.0.1', port: 28015);
  final encryption =  EncryptionService(Encrypter(AES(Key.fromLength(32))));
  late MessageService sut = MessageService(r, connection, encryption);


  final user1 = User.fromJson({
    'username': '1111',
    'id' : '1111',
    'photo_url': 'img',
    'active': true,
    'last_seen': DateTime.now()
  });

  final user2 = User.fromJson({
    'username': '2222',
    'id' : '2222',
    'photo_url': 'img',
    'active': true,
    'last_seen': DateTime.now()
  });

  const content = 'TESTINGTESTING!';

  final Message message1 = Message(
      from: user2.id!,
      to: user1.id!,
      timestamp: DateTime.now(),
      contents: content);

  final Message message2 = Message(
      from: user2.id!,
      to: user1.id!,
      timestamp: DateTime.now(),
      contents: content);

  setUp(() async {
    await createDb(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  test('Send message', () async {
    final res = await sut.send(message: message1);
    expect(res, true);
  });

  test('Subscribe and receive messages', () async {
    sut.messageStream(activeUser: user1).listen(expectAsync1((message) {
      expect(message.to, user1.id);
      expect(message.id, isNotEmpty);
      expect(message.contents, content);
    }, count: 2));

    await sut.send(message: message1);
    await sut.send(message: message2);
  });

  test('Subscribe and receive new messages when logging on', () async {
    /// Sending the messages first
    await sut.send(message: message1);
    await sut.send(message: message2)

    /// And then subscribing to the stream
        .whenComplete(() =>
        sut.messageStream(activeUser: user1).listen(expectAsync1((message) {
          expect(message.to, user1.id);
          expect(message.id, isNotEmpty);
    }, count: 2)));
  });
}