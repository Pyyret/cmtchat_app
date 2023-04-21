import 'package:isar/isar.dart';
import 'users.dart';
import 'messages.dart';

part 'chats.g.dart';


@Collection()
@Name('Chats')
class Chat {

  final Id id = Isar.autoIncrement;
  late final String? webId;

  final owner = IsarLink<User>();
  final mostRecentMessage = IsarLink<LocalMessage>();
  final allMessages = IsarLinks<LocalMessage>();

  String? chatName;
  int? unread;

  /// Constructor
  Chat({ required User chatOwner, this.chatName }) {
    owner.value = chatOwner;
  }


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