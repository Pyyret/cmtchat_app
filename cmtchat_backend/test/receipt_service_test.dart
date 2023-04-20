import 'package:cmtchat_backend/src/models/receipt.dart';
import 'package:cmtchat_backend/src/models/user.dart';
import 'package:cmtchat_backend/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late ReceiptService sut;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    sut = ReceiptService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    'id': '1234',
    'username': '1234',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
  });

  test('Sending receipt', () async {
    Receipt receipt = Receipt(
        recipient: user.id!,
        messageId: '1234',
        status: ReceiptStatus.sent,
        timestamp: DateTime.now()
    );

    final res = await sut.send(receipt);
    expect(res, true);
  });

  test('Receiving receipt', () async {
    sut.receiptStream(user).listen((receipt) {
      expect(receipt.recipient, user.id!);
      expect(receipt.status, ReceiptStatus.sent);
    });

    Receipt receipt = Receipt(
        recipient: user.id!,
        messageId: '1234',
        status: ReceiptStatus.sent,
        timestamp: DateTime.now());

    sut.send(receipt);
  });
}