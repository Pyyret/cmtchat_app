import 'package:cmtchat_app/data/datasources/sqflite_datasource.dart';
import 'package:cmtchat_app/models/chat.dart';
import 'package:cmtchat_backend/cmtchat_backend.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';


class MockSqfliteDatabase extends Mock implements Database {}
class MockBatch extends Mock implements Batch {}


void main() {
  SqfliteDatabase dB = MockSqfliteDatabase().;
  SqfliteDatasource sut = SqfliteDatasource(dB);
  MockBatch mockBatch = MockBatch();

  final Message message = Message.fromJson({
    'from' : '111',
    'to' : '222',
    'contents' : '--CENSORED--',
    'timestamp' : DateTime.parse('2020-04-20'),
    'id' : '4444'
  });

  test('Insert chat in database', () async {
    final chat = Chat(id: '3214', name: 'test');
    await sut.addChat(chat);

    verify(sut.addChat(chat)).called(1);
  });
}