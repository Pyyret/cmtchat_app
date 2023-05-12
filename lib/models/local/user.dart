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
  String? webUserId; // Online-specific variables

  String? username;
  String? photoUrl;
  bool? active;
  @Index()
  DateTime? lastSeen;

  // Links to the users chats & messages
  final chats = IsarLinks<Chat>();
  final sentMessages = IsarLinks<Message>();
  final receivedMessages = IsarLinks<Message>();

  User({
    this.webUserId,
    this.username,
    this.photoUrl,
    this.active,
    this.lastSeen});

  void update(WebUser webUser) {
    if (webUserId != webUser.webUserId) { return; }
    username = webUser.username;
    photoUrl = webUser.photoUrl;
    active = webUser.active;
    lastSeen = webUser.lastSeen;
  }

  factory User.empty() => User();
  factory User.noUser() => User(active: false, username: "No User!");
  factory User.fromWebUser({required WebUser webUser}) =>
      User(
          webUserId: webUser.webUserId,
          username: webUser.username,
          photoUrl: webUser.photoUrl,
          active: webUser.active,
          lastSeen: webUser.lastSeen);
}
