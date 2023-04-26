import 'package:cmtchat_app/models/local/user.dart';
import 'package:isar/isar.dart';

import 'message.dart';

part 'chat.g.dart';

@Collection()
@Name('Chats')
class Chat {
  Id id = Isar.autoIncrement;     // Automatically given by Isar

  // Links to the owner of the chatroom
  @Backlink(to: 'chats')
  final owners = IsarLinks<User>();

  // Links to messages in chatroom
  final messages = IsarLinks<Message>();

  // Optional
  String? chatName;
  int? unread;

  /// Constructor
  Chat({this.chatName});

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