import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/web/web_message.dart';

enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }
  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values.firstWhere((element) => element.value() == status);
  }
}

class Receipt {
  String get id => _id;
  final String recipient;
  final String messageId;
  final ReceiptStatus status;
  final DateTime timestamp;
  late final String _id;

  Receipt({
    required this.recipient,
    required this.messageId,
    required this.status,
    required this.timestamp});

  Map<String, dynamic> toJson() => {
    'recipient': recipient,
    'message_id': messageId,
    'status': status.value(),
    'timestamp': timestamp
  };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    var receipt = Receipt(
        recipient: json['recipient'],
        messageId: json['message_id'],
        status: EnumParsing.fromString(json['status']),
        timestamp: json['timestamp']
    );
    receipt._id = json['id'];
    return receipt;
  }

  factory Receipt.delivered({required WebMessage message}) =>
    Receipt(
        recipient: message.from,
        messageId: message.webId,
        status: ReceiptStatus.delivered,
        timestamp: DateTime.now()
    );

  factory Receipt.read({required Message message}) =>
      Receipt(
          recipient: message.from.value!.webId,
          messageId: message.webId,
          status: ReceiptStatus.read,
          timestamp: DateTime.now()
      );

}