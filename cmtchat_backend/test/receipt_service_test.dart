import 'package:cmtchat_backend/src/models/receipt.dart';
import 'package:cmtchat_backend/src/models/user.dart';
import 'package:cmtchat_backend/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';
import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService sut;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    sut = ReceiptService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    'id': '1234',
    'active': true,
    'last_seen': DateTime.now(),
  });
  
  test('Sending receipt', () async {
    Receipt receipt = Receipt(
        recipient: user.id,
        messageId: '1234',
        status: ReceiptStatus.sent,
        timestamp: DateTime.now()
    );

    final res = await sut.send(receipt);
    expect(res, true);
  });

  test('Receiving receipt', () async {
    sut.receipts(user).listen((receipt) {
      expect(receipt.recipient, user.id);
      expect(receipt.status, ReceiptStatus.sent);
    });

    Receipt receipt = Receipt(
        recipient: user.id,
        messageId: '1234',
        status: ReceiptStatus.sent,
        timestamp: DateTime.now());

    sut.send(receipt);
  });
}