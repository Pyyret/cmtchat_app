import 'package:isar/isar.dart';

import 'local_message.dart';

part 'chat.g.dart';

@Collection()
@Name('Chats')
class Chat {
  final Id isarId = Isar.autoIncrement;
  final String id;
  String? name;
  int unread = 0;
  List<LocalMessage> messages = [];
  late LocalMessage? mostRecent;

  /// Constructor
  Chat(this.name, this.unread, this.messages, this.mostRecent, {required this.id});

  /// Methods
  Map<String, dynamic> toMap() {
    return {
      'isarId' : isarId,
      'id': id,
      'name' : name,
      'unread' : unread,

    };
  }

  factory Chat.fromMap(Map<String, dynamic> json) => Chat(
    id: json['id'],
    name: json['name']
  );
}