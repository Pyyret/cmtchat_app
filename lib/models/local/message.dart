import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_message.dart';

import 'package:isar/isar.dart';

part 'message.g.dart';

/// Message ///
// Local representation of WebMessage.
// The @embedded annotation makes messages nestable in isar collections
@collection
@Name('Messages')
class Message {

  /// Variables
  Id id = Isar.autoIncrement;
  final String webId;               // Webserver-specific id.

  final String toWebId;
  final String fromWebId;
  final String contents;
  DateTime timestamp = DateTime.now();

  // Receipt data
  @enumerated
  ReceiptStatus receiptStatus;
  DateTime receiptTimestamp = DateTime.now();

  // Isar links
  final owner = IsarLink<User>();
  final chat = IsarLink<Chat>();

  /// Constructors
  Message({
    required this.webId,
    required this.toWebId,
    required this.fromWebId,
    required this.contents,
    required this.receiptStatus,
  });

  factory Message.fromWebMessage({
    required WebMessage message,
    required ReceiptStatus receiptStatus
  }) {
    return Message(
      toWebId: message.to,
      fromWebId: message.from,
      contents: message.contents,
      webId: message.webId,
      receiptStatus: receiptStatus,
    )
      ..timestamp = message.timestamp
      ..receiptTimestamp = DateTime.now();
  }

  /// Methods
  void updateReceipt({required Receipt receipt}) {
    receiptStatus = receipt.status;
    receiptTimestamp = receipt.timestamp;
  }
}