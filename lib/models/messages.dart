import 'package:cmtchat_app/models/chats.dart';
import 'package:cmtchat_app/models/users.dart';
import 'package:isar/isar.dart';

part 'messages.g.dart';

@Collection()
@Name('Messages')
class Message {
  Id id = Isar.autoIncrement;       // Automatically given by Isar
  String? webId;                    // Webserver-specific id.

  // Required message variables
  final DateTime timestamp;
  final String contents;

  // Links to sender, receiver & containing chatroom
  @Backlink(to: 'allSentMessages')
  final from = IsarLink<User>();
  @Backlink(to: 'allReceivedMessages')
  final to = IsarLink<User>();
  @Backlink(to: 'allMessages')
  final chat = IsarLink<Chat>();


  /// Constructor
  Message({required this.timestamp, required this.contents });

  /*
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

   */

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