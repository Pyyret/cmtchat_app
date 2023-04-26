import 'dart:async';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../encryption/encryption_contract.dart';


class WebMessageService implements IWebMessageService {
  final Connection _connection;
  final RethinkDb r;
  final IEncryption _encryption;
  late final StreamController<WebMessage> _controller;

  late StreamSubscription _changeFeed;

  /// Constructor
  WebMessageService(this.r, this._connection, this._encryption) {
    _controller = StreamController<WebMessage>.broadcast();
  }

  @override
  Future<bool> send({required WebMessage message}) async {
    var data = message.toJson();
    data['contents'] = _encryption.encrypt(message.contents);
    final response = await r
        .table('messages')
        .insert(data)
        .run(_connection);
    return response['inserted'] == 1;
  }

  @override
  Stream<WebMessage> messageStream({required WebUser activeUser}) {
    _startRecievingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<void> dispose() async {
    await _changeFeed.cancel();
    await _controller.close();
  }

  _startRecievingMessages(WebUser user) {
    _changeFeed = r
        .table('messages')
        .filter({'to' : user.webUserId})
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

  WebMessage _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    data['contents'] = _encryption.decrypt(data['contents']);
    return WebMessage.fromJson(data);
  }

  _removeDeliveredMessage(WebMessage message) {
    r
        .table('messages')
        .get(message.webId)
        .delete({'return_changes': false})
        .run(_connection);
  }
}