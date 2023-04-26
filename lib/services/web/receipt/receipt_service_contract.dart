import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_user.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);
  Stream<Receipt> receiptStream(WebUser user);
  void dispose();
}