import 'local_message.dart';

class Chat {
  String id;
  int unread = 0;
  List<LocalMessage>? messages = [];
  LocalMessage? mostRecent;

  /// Constructor
  Chat(this.id, {this.messages, this.mostRecent});

  /// Methods
  toMap() => {'id': id};

  factory Chat.fromMap(Map<String, dynamic> json) => Chat(json['id']);
}