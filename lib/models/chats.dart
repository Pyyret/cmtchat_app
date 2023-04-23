import 'package:isar/isar.dart';
import 'users.dart';
import 'messages.dart';

part 'chats.g.dart';


@Collection()
@Name('Chats')
class Chat {
  Id id = Isar.autoIncrement;     // Automatically given by Isar
  String? webChatId;                  // Webserver-specific id.

  // Links to the owner of the chatroom
  @Backlink(to: 'allChats')
  final owner = IsarLink<User>();

  // Links to messages in chatroom
  final allMessages = IsarLinks<LocalMessage>();

  // Optional
  String? chatName;
  int? unread;

  /// Constructor
  Chat({this.webChatId, this.chatName});

  /*

  /// Methods
  Map<String, dynamic> toMap() => {
    'isar_id': isarId,
    'id': id,
    'name': name,
    'unread': unread,
    'messages': messages.toList(),
    'most_recent' : mostRecent
  };

  factory Chat.fromMap(Map<String, dynamic> json) {
    Chat chat = Chat(json['name']);
    chat.isarId ??= json['isar_id'];
    chat.id ??= json['id'];
    chat.unread = json['unread'];
    chat.messages ??= json['messages'];
    chat.mostRecent ??= json['most_recent'];

    return chat;
  }

   */
}