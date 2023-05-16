import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'message.dart';
import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
@Name('Users')
class User {
  Id id = Isar.autoIncrement; // Automatically given by Isar
  @Index()
  final String webId; // Online-specific variables

  String username;
  bool active;
  @Index()
  DateTime? lastSeen;
  String? photoUrl;

  // Links to the users chats & messages
  final chats = IsarLinks<Chat>();
  final sentMessages = IsarLinks<Message>();
  final receivedMessages = IsarLinks<Message>();

  User({
    required this.webId,
    required this.username,
    required this.active,
    this.lastSeen,
    this.photoUrl
  });

  void update(WebUser webUser) {
    if (webId != webUser.id) { return; }
    username = webUser.username;
    photoUrl = webUser.photoUrl;
    active = webUser.active;
    lastSeen = webUser.lastSeen;
  }

  factory User.empty() =>
      User(webId: 'empty', username: 'empty', active: false);
  factory User.noUser() =>
      User(webId: 'No user', username: 'No user', active: false);
  factory User.fromWebUser({required WebUser webUser}) =>
      User(
          webId: webUser.id!,
          username: webUser.username,
          photoUrl: webUser.photoUrl,
          active: webUser.active,
          lastSeen: webUser.lastSeen);
}
