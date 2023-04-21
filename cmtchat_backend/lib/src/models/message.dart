import 'package:flutter/cupertino.dart';


class Message {
  final Id id = Isar.autoIncrement;
  final String from;
  final String to;
  final DateTime timestamp;
  final String contents;
  late final String? _id;

  Message({
    required this.from,
    required this.to,
    required this.timestamp,
    required this.contents,
  });

  Map<String, dynamic> toJson() {
    var data = {
      'from' : from,
      'to' : to,
      'timestamp' : timestamp,
      'contents' : contents
    };
    if(_id?.isNotEmpty ?? false) data['id'] = _id!;
    return data;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
        from: json['from'],
        to: json['to'],
        timestamp: json['timestamp'],
        contents: json['contents']
    );
    message._id = json['id'];
    return message;
  }
}