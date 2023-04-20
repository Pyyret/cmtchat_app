import 'package:cmtchat_backend/cmtchat_backend.dart';
import 'package:isar/isar.dart';


@Collection()
@Name('LocalMessages')
/// A local representation of a message
class LocalMessage {
  late final Id isarId;
  final String chatId;
  String? get id => message.id;
  final Message message;
  ReceiptStatus? receipt;

  /// Constructor
  LocalMessage({
    required this.chatId,
    required this.message
  }) {
   isarId = Isar.autoIncrement;
  }

  Map<String, dynamic> toMap() {
    var data = {
      'chat_id' : chatId,
      'id' : message.id,
      'sender' : message.from,
      'receiver' : message.to,
      'contents' : message.contents,
      'timestamp' : message.timestamp.toString()
    };
    if(receipt != null ?? false) data['receipt'] = receipt!.value();
    return data;
  }

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message.fromJson(json);
    final localMessage = LocalMessage(
        chatId : json['chat_id'],
        message : message
    );
    localMessage.receipt = json['receipt'];
    return localMessage;
  }
}