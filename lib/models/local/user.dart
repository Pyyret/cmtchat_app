import 'package:cmtchat_app/models/local/chat.dart';
import 'message.dart';
import 'package:isar/isar.dart';


part 'user.g.dart';

@Collection()
@Name('Users')
class User {
  Id id = Isar.autoIncrement;       // Automatically given by Isar
  final String webUserId ;              // Online-specific variables

  String? username;
  String? photoUrl;
  bool? active;
  DateTime? lastSeen;

  // Links to the users chats & messages
  final chats = IsarLinks<Chat>();
  final sentMessages = IsarLinks<Message>();
  final receivedMessages = IsarLinks<Message>();

  User({
    required this.webUserId,
    this.username,
    this.photoUrl,
    this.active,
    this.lastSeen
  });

  /// Constructors ///

}