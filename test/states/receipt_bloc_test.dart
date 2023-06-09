import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/receipt/receipt_service.dart';
import 'package:cmtchat_app/views/home/shared_blocs/receipt_bloc/receipt_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../web/helpers.dart';

Future<void> main() async {
  RethinkDb r = RethinkDb();
  final Connection connection = await r.connect(host: '127.0.0.1', port: 28015);
  ReceiptService receiptService = ReceiptService(r, connection);

  ReceiptBloc sut = ReceiptBloc(receiptService);
  WebUser user = WebUser.fromJson({
    'username': 'test',
    'photo_url': 'photoUrl',
    'active': true,
    'last_seen': DateTime.now(),
    'id' : '111'
  });

  setUp(() async {
    await createDb(r, connection);

    sut = ReceiptBloc(receiptService);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  tearDownAll(() async => await sut.close());


  test('Emit initial state if no subscriptions', () {
    expect(sut.state, ReceiptInitial());
  });

  test('Emit message sent state when message is sent', () {
    final receipt = Receipt(
        recipient: '123',
        messageId: '546',
        status: ReceiptStatus.read,
        timestamp: DateTime.now()
    );

    sut.add(ReceiptEvent.onReceiptSent(receipt));
    expectLater(sut.stream, emits(ReceiptState.sent(receipt)));
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