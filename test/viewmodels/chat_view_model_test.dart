import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/local/local_db_isar.dart';
import 'package:cmtchat_app/viewmodels/chat_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../data/path_provider_mock_classes.dart';

Future<void> main() async {
  PathProviderPlatform.instance = FakePathProviderPlatform();
  await Isar.initializeIsarCore(download: true);

  final LocalDbIsar i = LocalDbIsar();
  User _user = User(webId: '123');
  ChatViewModel sut = ChatViewModel(i, _user);

  setUp(() {
    _user = User(webId: '123');
    i.saveUser(_user);
    sut = ChatViewModel(i, _user);
  });

  tearDown(() => i.cleanDb());

  final webMessage1 = WebMessage.fromJson({
    'to' : 'webuser',
    'from' : '123',
    'timestamp' : DateTime.parse("2023-04-26"),
    'contents' : 'TESTING',
    'id' : '111'
  });
  
  final webMessage2 = WebMessage.fromJson({
    'to' : '123',
    'from' : 'webuser',
    'timestamp' : DateTime.parse("2023-04-26"),
    'contents' : 'TESTING',
    'id' : '222'
  });

  test('getMessages() returns empty list', () async {
    final emptyList = await sut.getMessages('webuser');
    expect(emptyList, isEmpty);
  });
  
  test('sentMessage() method working', () async {
    expect(sut.thisChat, isNull);

    await sut.sentMessage(webMessage1);
    expect(sut.thisChat, isNotNull);

    final chat = await i.findChat(sut.thisChat!.id);
    final ownerList = chat?.owners.toList();
    expect(ownerList?.length, 2);

    final messages = await sut.getMessages('webuser');
    expect(messages.length, 1);
    expect(messages.single.contents, 'TESTING');
  });

  test('receivedMessage() method working', () async {
    await sut.receivedMessage(webMessage1);
    expect(sut.otherMessages, 1);

  });
}