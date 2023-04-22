import 'package:cmtchat_app/models/chats.dart';
import 'package:cmtchat_app/models/users.dart';
import 'package:isar/isar.dart';

//part 'messages.g.dart';


/// The basic building-blocks for a message to send ///
class Message {

  final Id id = Isar.autoIncrement;
  late final String? webId;

  final from = IsarLink<User>();
  final to = IsarLink<User>();
  final DateTime timestamp;
  final String contents;


  Message({
    this.webId,
    required User from,
    required User to,
    required this.timestamp,
    required this.contents,
  }) {
    this.from.value = from;
    this.to.value = to;
  }

  Map<String, dynamic> toJson() {
    var data = {
      'from' : from,
      'to' : to,
      'timestamp' : timestamp,
      'contents' : contents
    };
    if(webId?.isNotEmpty ?? false) data['id'] = webId!;
    return data;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
        from: json['from'],
        to: json['to'],
        timestamp: json['timestamp'],
        contents: json['contents']
    );
    message.webId = json['id'];
    return message;
  }
}


/// A local representation of a message ///

//@Collection()
//@Name('Messages')
class LocalMessage extends Message {

  final chat = IsarLink<Chat>();

  //ReceiptStatus? receipt;

  /// Constructor
  LocalMessage({
    required super.from,
    required super.to,
    required super.timestamp,
    required super.contents,
    required Chat chat
  }) {
    this.chat.value = chat;
  }

  /*
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

   */
}