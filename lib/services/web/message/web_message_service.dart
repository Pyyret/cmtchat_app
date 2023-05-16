import 'dart:async';

import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/web/encryption/encryption_service_api.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_api.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';


class WebMessageService implements WebMessageServiceApi {
  final Connection _connection;
  final RethinkDb r;
  final EncryptionServiceApi? _encryption;

  final StreamController<WebMessage> _controller = StreamController<WebMessage>
      .broadcast();
  StreamSubscription? _changeFeed;

  /// Constructor
  WebMessageService(this.r, this._connection, {EncryptionServiceApi? encryption})
      : _encryption = encryption;

  @override
  Future<WebMessage> send({required WebMessage message}) async {
    var data = message.toJson();
    if(_encryption != null) {
      data['contents'] = _encryption!.encrypt(message.contents);
    }
    Map response = await r
        .table('messages')
        .insert(data, {'return_changes' : true})
        .run(_connection);
    return WebMessage.fromJson(response['changes'].first['new_val']);
  }

  @override
  Stream<WebMessage> messageStream({required String webUserId}) {
    _startRecievingMessages(webUserId);
    return _controller.stream;
  }


  _startRecievingMessages(String webUserId) {
    _changeFeed = r
        .table('messages')
        .filter({'to' : webUserId})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            print('message: $feedData');
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
    if(_encryption != null) {
      data['contents'] = _encryption!.decrypt(data['contents']);
    }
    return WebMessage.fromJson(data);
  }

  _removeDeliveredMessage(WebMessage message) {
    r
        .table('messages')
        .get(message.webId)
        .delete({'return_changes': false})
        .run(_connection);
  }



  @override
  Future<void> dispose() async {
    await _changeFeed?.cancel();
    await _controller.close();
  }


  @override
  Future<void> cancelChangeFeed() async {
    if(_changeFeed != null){
      await _changeFeed?.cancel();
    }
  }
}