import 'dart:async';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../../models/message.dart';
import '../../models/user.dart';
import '../encryption/encryption_contract.dart';
import 'message_service_contract.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final RethinkDb r;
  final IEncryption _encryption;
  late final StreamController<Message> _controller;

  late StreamSubscription _changeFeed;

  /// Constructor
  MessageService(this.r, this._connection, this._encryption) {
    _controller = StreamController<Message>.broadcast();
  }

  @override
  Future<bool> send({required Message message}) async {
    var data = message.toJson();
    data['contents'] = _encryption.encrypt(message.contents);
    final response = await r
        .table('messages')
        .insert(data)
        .run(_connection);
    return response['inserted'] == 1;
  }

  @override
  Stream<Message> messageStream({required User activeUser}) {
    _startRecievingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<void> dispose() async {
    await _changeFeed.cancel();
    await _controller.close();
  }

  _startRecievingMessages(User user) {
    _changeFeed = r
        .table('messages')
        .filter({'to' : user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if(feedData['new_val'] == null) return;
            final message = _messageFromFeed(feedData);
            _controller.sink.add(message);
            _removeDeliveredMessage(message);
          })
              .onError((err, stackTrace) => print(err));
        });
  }

  Message _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    data['contents'] = _encryption.decrypt(data['contents']);
    return Message.fromJson(data);
  }

  _removeDeliveredMessage(Message message) {
    r
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false})
        .run(_connection);
  }
}