import 'package:cmtchat_app/models/chats.dart';
import 'package:cmtchat_backend/cmtchat_backend.dart';

import 'package:flutter_test/flutter_test.dart';


void main() {
  final Message message = Message.fromJson({
    'from' : '111',
    'to' : '222',
    'contents' : '--CENSORED--',
    'timestamp' : DateTime.parse('2020-04-20'),
    'id' : '4444'
  });

  test('Insert chat in database', () async {
    final chat = Chat(null);
  });
}