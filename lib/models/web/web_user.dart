import 'package:isar/isar.dart';

part 'web_user.g.dart';


/// WebUser ///
@embedded
class WebUser {
  /// Variables
  final String id;
  String username;
  String photoUrl = '';
  bool active;
  DateTime lastSeen = DateTime.now();

  /// Constructors
  WebUser({this.id = '', this.username = '', this.active = false});
  factory WebUser.fromJson(Map<String, dynamic> json) {
    return WebUser(
        id: json['id'],
        username: json['username'],
        active: json['active']
    )
      ..photoUrl = json['photo_url']
      ..lastSeen = json['last_seen'];
  }

  /// Method
  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'username': username,
      'photo_url': photoUrl,
      'active': active,
      'last_seen': lastSeen
    };
}
