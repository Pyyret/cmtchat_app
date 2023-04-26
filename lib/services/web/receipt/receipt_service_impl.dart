import 'dart:async';

import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'receipt_service_contract.dart';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final RethinkDb r;
  late final StreamController<Receipt> _controller;

  late StreamSubscription _changeFeed;

  /// Constructor
  ReceiptService(this.r, this._connection){
    _controller = StreamController<Receipt>.broadcast();
  }

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
  Stream<Receipt> receiptStream(WebUser user) {
    _startRecievingReceipts(user);
    return _controller.stream;
  }

  @override
  dispose() {
    _changeFeed.cancel();
    _controller.close();
  }

  _startRecievingReceipts(WebUser user) {
    _changeFeed = r
        .table('receipts')
        .filter({'recipient' : user.webUserId})
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