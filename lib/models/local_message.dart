import 'package:cmtchat_backend/cmtchat_backend.dart';

/// A local representation of a message
class LocalMessage {
  String get id => _id;
  String chatId;
  Message message;
  ReceiptStatus receipt;
  late String _id;

  /// Constructor
  LocalMessage(this.chatId, this.message, this.receipt);

  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'id': message.id,
    'receipt': receipt.value(),
    ... message.toJson()
  };

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message(
        from: json['from'],
        to: json['to'],
        timestamp: json['timestamp'],
        contents: json['contents']
    );
    final localMessage = LocalMessage(json['chat_id'], message, json['receipt']);
    localMessage._id = json['id'];

    return localMessage;
  }
}