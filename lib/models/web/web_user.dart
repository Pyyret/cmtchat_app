class WebUser {
  String? get webId => _webId;
  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;
  String? _webId;

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
    if(_webId?.isNotEmpty ?? false) data['id'] = _webId!;
    return data;
  }

  factory WebUser.fromJson(Map<String, dynamic> json) {
    final user = WebUser(
        username: json['username'],
        photoUrl: json['photo_url'],
        active: json['active'],
        lastSeen: json['last_seen']
    );
    user._webId = json['id'];
    return user;
  }
}