import 'package:cmtchat_app/models/local/user.dart';
import 'package:isar/isar.dart';

import 'message.dart';

part 'chat.g.dart';

@Collection()
@Name('Chats')
class Chat {
  Id id = Isar.autoIncrement;    // Automatically given by Isar

  String chatName = '';         // Set to the username that is not user by isar
  int unread = 0;               // Number of messages with 'delivered' status
  @Index()
  DateTime lastUpdate = DateTime.now();     // Set to datetime of last message
  String lastMessageContents = '';          // Set by isar

  // Links to the owners of the chatroom
  @Backlink(to: 'chats')
  final owners = IsarLinks<User>();

  // Links to messages in chatroom
  final messages = IsarLinks<Message>();


  /// Constructor
  Chat({this.chatName = ''});
}