import 'package:flutter/foundation.dart';

class User {
  String get id => _id;
  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;
  String _id;

  User({
    @required this.username,
    @required this.photoUrl,
    @required this.active,
    @required this.lastSeen});

  toJson() => {
    'username': username,
    'photo_url': photoUrl,
    'active': active,
    'last_seen': lastSeen
  };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        username: json['username'],
        photoUrl: json['photo_url'],
        active: json['active'],
        lastSeen: json['last_seen']
    );
    user._id = json['id'];
    return user;
  }
}