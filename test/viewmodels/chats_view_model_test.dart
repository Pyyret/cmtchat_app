import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/local/data/isar_local_db.dart';
import 'package:cmtchat_app/viewmodels/chats_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../data/path_provider_mock_classes.dart';

Future<void> main() async {
  PathProviderPlatform.instance = FakePathProviderPlatform();
  await Isar.initializeIsarCore(download: true);

  final IsarLocalDb i = IsarLocalDb();
  User _user = User(webId: '123');
  ChatsViewModel sut = ChatsViewModel(i, _user);

  setUp(() {
    _user = User(webId: '123');
    i.saveUser(_user);
    sut = ChatsViewModel(i, _user);
  });

  tearDown(() => i.cleanDb());

  final webMessage = WebMessage.fromJson({
    'to' : '123',
    'from' : 'webuser',
    'timestamp' : DateTime.parse("2023-04-26"),
    'contents' : 'TESTING',
    'id' : '111'
  });

  test('getChats() returns empty list or chatlist', () async {
    final emptyList = await sut.getChats();
    expect(emptyList, isEmpty);

    final chat = Chat();
    chat.owners.add(_user);
    i.saveChat(chat);

    final list = await sut.getChats();
    expect(list, isNotEmpty);
    expect(list.length, 1);
  });

  test('receivedMessage() method working', () async {
    sut.receivedMessage(webMessage);

    final list = await sut.getChats();
    expect(list.length, 1);

    sut.receivedMessage(webMessage);

    final listagain = await sut.getChats();
    expect(listagain.length, 1);
    expect(listagain.single.messages.toList().length, 2);


  });
}