import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_user.dart';

abstract class ReceiptServiceApi {
  Future<bool> send(Receipt receipt);
  Future<bool> sendList(List<Receipt> receiptList);
  Stream<Receipt> receiptStream({required WebUser activeUser});
  Future<void> cancelChangeFeed();
  void dispose();
}