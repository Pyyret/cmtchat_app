import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/web/encryption/encryption_service_impl.dart';
import 'package:cmtchat_app/services/web/message/web_message_service.dart';
import 'package:cmtchat_app/states_management/web_message/web_message_bloc.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../web/helpers.dart';

Future<void> main() async {
  RethinkDb r = RethinkDb();
  final Connection connection = await r.connect(host: '127.0.0.1', port: 28015);
  final encryption =  EncryptionService(Encrypter(AES(Key.fromLength(32))));
  WebMessageService messageService = WebMessageService(r, connection, encryption: encryption);

  WebMessageBloc sut = WebMessageBloc(messageService);

  setUp(() async {
    await createDb(r, connection);
    sut = WebMessageBloc(messageService);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  tearDownAll(() async => await sut.close());


  test('Emit initial state if no subscriptions', () {
    expect(sut.state, WebMessageInitial());
  });

  test('Emit message sent state when message is sent', () {
    final message = WebMessage(
        to: '456',
        from: '123',
        timestamp: DateTime.now(),
        contents: 'testing'
    );

    sut.add(WebMessageEvent.onMessageSent(message));
    expectLater(sut.stream, emits(WebMessageState.sent(message)));
  });

/*
  test('Emit message received from service', () {
    final message = WebMessage(
        to: '111',
        from: '123',
        timestamp: DateTime.now(),
        contents: 'testing'
    );

    sut.add(WebMessageEvent.onSubscribed(user));
    messageService.send(message: message);
    expectLater(sut.stream, emitsInOrder([WebMessageReceivedSuccess(message)]));

  });


 */
}