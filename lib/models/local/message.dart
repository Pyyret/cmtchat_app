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
  DateTime? timestamp;
  final String contents;

  // Receipt data
  @Enumerated(EnumType.name)
  ReceiptStatus? status;
  DateTime? receiptTimestamp;

  // Isar links to sender, receiver & containing chatroom
  @Backlink(to: 'receivedMessages')
  final to = IsarLink<User>();

  @Backlink(to: 'sentMessages')
  final from = IsarLink<User>();

  @Backlink(to: 'messages')
  final chat = IsarLink<Chat>();


  // Constructor
  Message({
    this.webId,
    this.timestamp,
    required this.contents,
    this.status,
    this.receiptTimestamp
  });

}