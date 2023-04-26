class WebUser {
  String? get webUserId => _webUserId;
  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;
  String? _webUserId;

  WebUser({
    required this.username,
    required this.photoUrl,
    required this.active,
    required this.lastSeen});

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
}