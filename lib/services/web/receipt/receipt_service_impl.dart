import 'dart:async';

import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'receipt_service_contract.dart';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final RethinkDb r;
  final StreamController<Receipt> _controller = StreamController<Receipt>.broadcast();

  StreamSubscription? _changeFeed;

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
  Stream<Receipt> receiptStream({required WebUser activeUser}) {
    _startRecievingReceipts(activeUser);
    return _controller.stream;
  }

  @override
  dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }

  _startRecievingReceipts(WebUser activeUser) {
    _changeFeed = r
        .table('receipts')
        .filter({'recipient' : activeUser.webUserId})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if(feedData['new_val'] == null) return;
            final receipt = _receiptFromFeed(feedData);
            _controller.sink.add(receipt);
            _removeDeliveredReceipt(receipt);
          })
              .onError((err, stackTrace) => print(err));
        });
  }

  Receipt _receiptFromFeed(feedData) {
    var data = feedData['new_val'];
    return Receipt.fromJson(data);
  }

  _removeDeliveredReceipt(Receipt receipt) async {
    r.table('receipts')
        .get(receipt.id)
        .delete({'return_changes': false})
        .run(_connection);
  }
}