
@Collection()
@Name('Chats')
class Chat {
  final Id isarId = Isar.autoIncrement;
  late final String? id;
  String? name;
  int? unread;

  final messages = IsarLinks<LocalMessage>();
  final mostRecentMsg = IsarLink<LocalMessage>();
}

@Collection()
@Name('LocalMessages')
class LocalMessage {
  late final Id isarId;
  late final String? chatId;
  late final Message message;

  @Enumerated(EnumType.name)
  ReceiptStatus? receipt;
}

@Embedded()
@Name('Messages')
class Message {
  String? get id => _id;
  late final String from;
  late final String to;
  late final DateTime timestamp;
  late final String contents;
  late final String? _id;
}

@Collection()
@Name('Receipts')
class Receipt {
  late final Id isarId;
  String get id => _id;
  late final String recipient;
  late final String messageId;

  @Enumerated(EnumType.name)
  late final ReceiptStatus status;
  late final DateTime timestamp;
  late final String _id;
}
enum ReceiptStatus { sent, delivered, read }

@Collection()
@Name('TypingEvents')
class TypingEvent {
  late final Id isarId;
  String get id => _id;
  late final String to;
  late final String from;
  @Enumerated(EnumType.name)
  late Typing event;
  late String _id;
}
enum Typing { start, stop }

@Collection()
@Name('Users')
class User {
  late final Id isarId;
  String? get id => _id;
  late String username;
  late String photoUrl;
  late bool active;
  late DateTime lastSeen;
  String? _id;
}