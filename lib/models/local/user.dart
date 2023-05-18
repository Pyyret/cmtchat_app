import 'package:cmtchat_app/collections/models.dart';
import 'package:isar/isar.dart';

part 'user.g.dart';

/// User ///
@Collection()
@Name('Users')
class User {
  /// Variables
  Id id = Isar.autoIncrement; // Automatically given by Isar

  final WebUser webUser;    // Most user data is in this internal webUser

  // Isar links
  @Backlink(to: 'owner')
  final sentMessages = IsarLinks<Message>();
  @Backlink(to: 'owner')
  final receivedMessages = IsarLinks<Message>();
  @Backlink(to: 'owner')
  final chats = IsarLinks<Chat>();    // isar links to the users chats

  /// Constructors
  User(this.webUser);
  factory User.empty() => User(WebUser(username: 'No User', active: false));

  /// Getters
  String get webId => webUser.id;
  String get username => webUser.username;
  String? get photoUrl => webUser.photoUrl;
  bool get active => webUser.active;
  DateTime get lastSeen => webUser.lastSeen;

  /// Method
 bool isUpdatedFrom({required WebUser? webUser}) {
   if(webUser != null && webUser.id == webId) {
     this.webUser
       ..username = webUser.username
       ..photoUrl = webUser.photoUrl
       ..active = webUser.active
       ..lastSeen = webUser.lastSeen;
     return true;
   }
   else { return false; }
 }
}
