import 'dart:async';

import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../../models/receipt.dart';
import '../../models/user.dart';
import 'receipt_service_contract.dart';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final RethinkDb r;
  final _controller = StreamController<Receipt>.broadcast();

  late StreamSubscription _changeFeed;

  /// Constructor
  ReceiptService(this.r, this._connection);

  /// Methods
  @override
  Future<bool> send(Receipt receipt) async {
    var data = receipt.toJson();
    Map record = await r
        .table('receipts')
        .insert(data)
        .run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<Receipt> receipts(User user) {
    _startRecievingReceipts(user);
    return _controller.stream;
  }

  @override
  dispose() {
    _changeFeed.cancel();
    _controller.close();
  }

  _startRecievingReceipts(User user) {
    _changeFeed = r
        .table('receipts')
        .filter({'recipient' : user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if(feedData['new_val'] == null) return;
            final receipt = _receiptFromFeed(feedData);
            _controller.sink.add(receipt);
          })
              .onError((err, stackTrace) => print(err));
        });
  }

  Receipt _receiptFromFeed(feedData) {
    var data = feedData['new_val'];
    return Receipt.fromJson(data);
  }
}