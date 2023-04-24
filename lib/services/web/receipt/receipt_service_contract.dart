import '../../../../../lib/models/web/receipt.dart';
import '../../models/user.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);
  Stream<Receipt> receiptStream(User user);
  void dispose();
}