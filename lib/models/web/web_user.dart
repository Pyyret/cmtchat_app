import 'package:cmtchat_app/models/local/user.dart';

class WebUser {
  String? get webUserId => _webUserId;
  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;
  String? _webUserId;

  WebUser({
    this.username = '',
    this.photoUrl = '',
    this.active = false,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    var data = {
      'username': username,
      'photo_url': photoUrl,
      'active': active,
      'last_seen': lastSeen
    };
    if(_webUserId?.isNotEmpty ?? false) data['id'] = _webUserId!;
    return data;
  }

  factory WebUser.fromJson(Map<String, dynamic> json) {
    final user = WebUser(
        username: json['username'],
        photoUrl: json['photo_url'],
        active: json['active'],
        lastSeen: json['last_seen']
    );
    user._webUserId = json['id'];
    return user;
  }

  factory WebUser.fromUser(User user) {
    final webUser = WebUser(
        username: user.username ?? '',
        photoUrl: user.photoUrl ?? '',
        active: user.active ?? false,
        lastSeen: user.lastSeen ?? DateTime.now()
    );
    webUser._webUserId = user.webUserId;
    return webUser;
  }
}