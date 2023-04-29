import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'message.dart';
import 'package:isar/isar.dart';


part 'user.g.dart';

@Collection()
@Name('Users')
class User {
  Id id = Isar.autoIncrement;       // Automatically given by Isar
  late final String webUserId ;              // Online-specific variables

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

  @ignore
  factory User.fromWebUser({required WebUser webUser}) {
    final user = User(webUserId: webUser.webUserId!);
    user.username = webUser.username;
    user.photoUrl = webUser.photoUrl;
    user.active = webUser.active;
    user.lastSeen = webUser.lastSeen;
    return user;
  }

  void update(WebUser webUser) {
    if(webUserId != webUser.webUserId) { return; }
    username = webUser.username;
    photoUrl = webUser.photoUrl;
    active = webUser.active;
    lastSeen = webUser.lastSeen;
  }

}