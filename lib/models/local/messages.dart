import 'package:cmtchat_app/models/local/chats.dart';
import 'package:cmtchat_app/models/local/users.dart';
import 'package:isar/isar.dart';


part 'messages.g.dart';


@Collection()
@Name('Messages')

/// LocalMessage ///
class LocalMessage {
  Id id = Isar.autoIncrement;       // Automatically given by Isar

  // Necessary parts of a local message
  Message message;
  Receipt? receipt;

  // Isar links to sender, receiver & containing chatroom
  @Backlink(to: 'allSentMessages')
  final isarFrom = IsarLink<User>();
  @Backlink(to: 'allReceivedMessages')
  final isarTo = IsarLink<User>();
  @Backlink(to: 'allMessages')
  final chat = IsarLink<Chat>();


  /// Constructor
  LocalMessage({ required this.message, this.receipt});

}

/// Message ///

@embedded
class Message {
  String? webId;                    // Webserver-specific id.
  String? webChatId;                // Webserver-specific chatId.

  String? from;
  String? to;
  DateTime? timestamp;
  String? contents;

  Message({this.webChatId, this.from, this.to, this.timestamp, this.contents, this.webId});


  Map<String, dynamic> toJson() {
    var data = {
      'from' : from,
      'to' : to,
      'timestamp' : timestamp,
      'contents' : contents
    };
    if(webId?.isNotEmpty ?? false) data['id'] = webId!;
    return data;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
        from: json['from'],
        to: json['to'],
        timestamp: json['timestamp'],
        contents: json['contents']
    );
    message.webId = json['id'];

    return message;
  }
}

/// Receipt ///

enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }
  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values.firstWhere((element) => element.value() == status);
  }
}

@embedded
class Receipt {
  String? webId;                    // Webserver-specific id.

  @Enumerated(EnumType.name)
  ReceiptStatus? status;
  DateTime? timestamp;

  Receipt({this.status, this.timestamp, this.webId});

  /*
  Map<String, dynamic> toJson() => {
    'recipient': recipient,
    'message_id': messageId,
    'status': status.value(),
    'timestamp': timestamp
  };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    var receipt = Receipt(
        recipient: json['recipient'],
        messageId: json['message_id'],
        status: EnumParsing.fromString(json['status']),
        timestamp: json['timestamp']
    );
    receipt._id = json['id'];
    return receipt;
  }

   */
}

/*
  Map<String, dynamic> toMap() {
    var data = {
      'chat_id' : chatId,
      'id' : message.id,
      'sender' : message.from,
      'receiver' : message.to,
      'contents' : message.contents,
      'timestamp' : message.timestamp.toString()
    };
    if(receipt != null ?? false) data['receipt'] = receipt!.value();
    return data;
  }

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message.fromJson(json);
    final localMessage = LocalMessage(
        chatId : json['chat_id'],
        message : message
    );
    localMessage.receipt = json['receipt'];
    return localMessage;
  }

   */