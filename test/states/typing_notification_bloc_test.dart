import 'package:cmtchat_app/models/web/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/typing/typing_notification_service_impl.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_api.dart';
import 'package:cmtchat_app/services/web/user/web_user_service.dart';
import 'package:cmtchat_app/states_management/typing/typing_notification_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../web/helpers.dart';

Future<void> main() async {
  RethinkDb r = RethinkDb();
  final Connection connection = await r.connect(host: '127.0.0.1', port: 28015);
  WebUserServiceApi webUserService = WebUserService(r, connection);
  TypingNotification typingNotificationService = TypingNotification(r, connection,webUserService);

  TypingNotificationBloc sut = TypingNotificationBloc(typingNotificationService);

  WebUser user = WebUser.fromJson({
    'username': 'test',
    'photo_url': 'photoUrl',
    'active': true,
    'last_seen': DateTime.now(),
    'id' : '111'
  });

  setUp(() async {
    await createDb(r, connection);

    sut = TypingNotificationBloc(typingNotificationService);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  tearDownAll(() async => await sut.close());


  test('Emit initial state if no subscriptions', () {
    expect(sut.state, TypingNotificationState.initial());
  });

  test('Emit typingNotification sent state when it is sent', () {
    //webUserService.connect(user);
    final typingEvent = TypingEvent(
        to: user.webUserId!,
        from: '123',
        event: Typing.start
    );

    sut.add(TypingNotificationEvent.onTypingEventSent(typingEvent));
    expectLater(sut.stream, emits(TypingNotificationState.sent()));
  });

/*
  test('Emit message received from service', () {
    final receipt = Receipt(
        recipient: '111',
        messageId: '546',
        status: ReceiptStatus.read,
        timestamp: DateTime.now()
    );

    sut.add(ReceiptEvent.onSubscribed(user));
    expectLater(sut.stream, emitsInOrder([ReceiptReceivedSuccess(receipt)]));
    receiptService.send(receipt);
  });


 */


}