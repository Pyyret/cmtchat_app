import 'package:cmtchat_app/models/local/user.dart';

class WebUser {
  String? get id => _id;
  String username;
  String photoUrl = '';
  bool active = false;
  DateTime lastSeen = DateTime.now();
  String? _id;

  WebUser({required this.username});

  Map<String, dynamic> toJson() {
    var data = {
      'username': username,
      'photo_url': photoUrl,
      'active': active,
      'last_seen': lastSeen
    };
    if(_id?.isNotEmpty ?? false) data['id'] = _id!;
    return data;
  }

  factory WebUser.fromJson(Map<String, dynamic> json) {
    return WebUser(username: json['username'])
      ..photoUrl = json['photo_url']
      ..active = json['active']
      ..lastSeen = json['last_seen']
      .._id = json['id'];
  }

  factory WebUser.fromUser({required User user}) {
    return WebUser(username: user.username)
      ..photoUrl = user.photoUrl ?? ''
      ..active = user.active
      ..lastSeen =  user.lastSeen ?? DateTime.now()
      .._id = user.webId;
  }
}