import 'package:cmtchat_app/collections/models.dart';
import 'package:isar/isar.dart';

part 'chat.g.dart';

/// Chats ///
@collection
@Name('Chats')
class Chat {

  /// Variables
  Id id = Isar.autoIncrement;   // Automatically given by Isar

  final String ownerWebId;
  final WebUser receiver;
  String chatName;
  final DateTime creationTime = DateTime.now();

  // Isar links
  @Backlink(to: 'chat')
  final messages = IsarLinks<Message>();
  final owner = IsarLink<User>();

  /// Constructor
  Chat({required this.ownerWebId, required this.receiver})
      : chatName = receiver.username;

  /// Getters
  String get receiverWebId => receiver.id;
  @ignore
  String get lastMessageContents => messages.isNotEmpty
      ? messages.last.contents : '';
  @ignore
  DateTime get lastUpdate => messages.isNotEmpty
      ? messages.last.timestamp : creationTime;
  @ignore
  int get unread => messages.where(
          (msg) => msg.toWebId == ownerWebId
              && msg.receiptStatus != ReceiptStatus.read).length;
}