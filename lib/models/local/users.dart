import 'package:cmtchat_app/models/local/chats.dart';
import 'messages.dart';
import 'package:isar/isar.dart';

part 'users.g.dart';


@Collection()
@Name('Users')

class User {
  Id id = Isar.autoIncrement;     // Automatically given by Isar
  WebUser? webUser;               // Online-specific variables

  // Defaults to 'Guest', necessary for many things
  String username = '';

  // Links to all your chats & messages
  final allChats = IsarLinks<Chat>();
  final allSentMessages = IsarLinks<LocalMessage>();
  final allReceivedMessages = IsarLinks<LocalMessage>();


  /// Constructors ///
  User({String? newUsername}){ username = newUsername ?? 'Guest'; }    // Gives option to add username, otherwise 'Guest'
  User.newAccount({required this.username});                          // Requires at least a username
  User.webUser({required this.username, required this.webUser});
  User.allChangeable({
    required this.username,
    String? webId,
    String? photoUrl,
    DateTime? lastSeen,
    bool? active}) {
    webUser = WebUser.changeable(webId: webId, photoUrl: photoUrl);
    webUser?.lastSeen = lastSeen;
  }
}

@embedded
class WebUser {

  late final String? webId;     // Webserver-specific id.
  bool active = false;          // Active status online/offline
  DateTime? lastSeen;           // Last time seen on webserver
  String? photoUrl;             // Url to profile picture


  // Constructors
  WebUser();
  WebUser.changeable({this.webId, this.photoUrl});



  Map<String, dynamic> toJson() {
    var data = {
      'id' : webId,
      'photo_url': photoUrl,
      'active': active,
      'last_seen': lastSeen
    };
    if(webId?.isNotEmpty ?? false) data['id'] = webId!;
    return data;
  }



/*
  factory WebUser.fromJson(Map<String, dynamic> json) {
    final user = WebUser(
        username: json['username'],
        photoUrl: json['photo_url'],
        active: json['active'],
        lastSeen: json['last_seen']
    );
    user.id = json['id']
    return user;
  }
   */
}