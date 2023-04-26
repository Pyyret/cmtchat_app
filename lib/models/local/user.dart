import 'package:cmtchat_app/models/local/chat.dart';
import 'message.dart';
import 'package:isar/isar.dart';


part 'user.g.dart';

@Collection()
@Name('Users')
class User {
  Id id = Isar.autoIncrement;       // Automatically given by Isar
  final String webId ;              // Online-specific variables

  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;

  // Links to the users chats & messages
  final chats = IsarLinks<Chat>();
  final sentMessages = IsarLinks<Message>();
  final receivedMessages = IsarLinks<Message>();

  User({
    required this.webId,
    required this.username,
    required this.photoUrl,
    required this.active,
    required this.lastSeen
  });

  /// Constructors ///

}