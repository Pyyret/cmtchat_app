import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/web/web_message.dart';

/// ReceiptStatus Enum ///
enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String value() { return toString().split('.').last; }
  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values.firstWhere((element) => element.value() == status);
  }
}

/// Receipt ///
class Receipt {
  /// Variables
  // _id is set by rethink db when message receives at it
  String get id => _id;
  final String recipient;
  final String messageId;
  final ReceiptStatus status;
  final DateTime timestamp;
  late final String _id;

  /// Constructors ///
  Receipt({
    required this.recipient,
    required this.messageId,
    required this.status,
    required this.timestamp
  });

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
          recipient: message.fromWebId,
          messageId: message.webId,
          status: ReceiptStatus.read,
          timestamp: DateTime.now()
      );

  Map<String, dynamic> toJson() => {
    'recipient': recipient,
    'message_id': messageId,
    'status': status.value(),
    'timestamp': timestamp
  };
}