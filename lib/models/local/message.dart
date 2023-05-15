import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:isar/isar.dart';


part 'message.g.dart';

@Collection()
@Name('Messages')
class Message {
  Id id = Isar.autoIncrement;            // Automatically given and used by Isar
  String? webId;                        // Webserver-specific id.

  @Index()
  DateTime timestamp;
  final String contents;

  // Receipt data
  @Enumerated(EnumType.name)
  ReceiptStatus status;
  DateTime receiptTimestamp;

  // Isar links to sender, receiver & containing chatroom
  @Backlink(to: 'receivedMessages')
  final to = IsarLink<User>();

  @Backlink(to: 'sentMessages')
  final from = IsarLink<User>();

  @Backlink(to: 'messages')
  final chat = IsarLink<Chat>();


  /// Constructors
  Message({
    this.webId,
    required this.timestamp,
    required this.contents,
    required this.status,
    required this.receiptTimestamp,
  });

  factory Message.fromWebMessage({required WebMessage message})
  {
    return Message(
      webId: message.webId,
      timestamp: message.timestamp,
      contents: message.contents,
      status: ReceiptStatus.delivered,
      receiptTimestamp: DateTime.now()
    );
  }
}