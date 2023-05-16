import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/services/local/local_db_isar.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_mock_classes.dart';


Future<void> main() async {
  PathProviderPlatform.instance = FakePathProviderPlatform();
  await Isar.initializeIsarCore(download: true);

  final LocalDbIsar i = LocalDbIsar();

  User user1 = User(
      webId: '111',
      username: '111',
      photoUrl: 'url',
      active: false,
      lastSeen: DateTime.now());

  User user2 = User(
      webId: '222',
      username: '222',
      photoUrl: 'url',
      active: false,
      lastSeen: DateTime.now());

  Chat chat1 = Chat(chatName: 'chat1');
  Chat chat2 = Chat(chatName: 'chat2');

  group('Path_provider dependant tests', () {

    setUp(() async {
      user1 = User(
          webId: '111',
          username: '111',
          photoUrl: 'url',
          active: false,
          lastSeen: DateTime.now());

      user2 = User(
          webId: '222',
          username: '222',
          photoUrl: 'url',
          active: false,
          lastSeen: DateTime.now());

      chat1 = Chat(chatName: 'chat1');
      chat2 = Chat(chatName: 'chat2');
    });

    tearDown(() async => await i.cleanDb());


    // Just to test since this has been a problem during development
    test('Testing that "getApplicationDocumentsDirectory()" is working', () async {
        var dir = await getApplicationDocumentsDirectory();
        expect(dir, isNotNull);
    });

    test('Add and retrieve a user to the db, then remove', () async {
      await i.saveUser(user1);

      User? dbUser = await i.findUser(user1.id);

      expect(dbUser?.id, user1.id);
      expect(dbUser?.username, user1.username);

      await i.removeUser(user1.id);

      expect(await i.findUser(user1.id), isNull);
    });

    test('Add and retrieve a chat to the db, then remove', () async {

      await i.saveChat(chat1);
      Chat? dbChat = await i.findChat(chat1.id);

      expect(dbChat, isNotNull);
      expect(dbChat?.id, chat1.id);
      expect(dbChat?.chatName, chat1.chatName);

      await i.removeChat(chat1.id);
      expect(await i.findChat(chat1.id), isNull);
      expect(chat1, isNotNull);
    });

    test('Add owner link to chat, and test backlink', () async {

      // Testing that user1 is registered as the owner
      chat1.owners.add(user1);
      await i.saveChat(chat1);

      Chat? dbChat = await i.findChat(chat1.id);
      User? chatOwner = dbChat?.owners.single;

      expect(chatOwner, isNotNull);
      expect(chatOwner?.id, user1.id);
      expect(chatOwner?.username, '111');

      // Testing that backlink works
      User? dbUser = await i.findUser(user1.id);
      Chat? user1Chats = dbUser?.chats.first;

      expect(user1Chats, isNotNull);
      expect(user1Chats?.id, chat1.id);
    });

    test('Link multiple chats to user and checking backlink', () async {
      user1.chats.add(chat1);
      user1.chats.add(chat2);

      await i.saveUser(user1);

      User? dbUser = await i.findUser(user1.id);
      List<Chat>? dbUserChats = await i.findAllChats(dbUser!.id);

      expect(dbUserChats, isNotNull);
      expect(dbUserChats.length, 2);

      // Here testing that backlink works also
      expect(dbUserChats.first.owners.single.id, user1.id);

      // Test that removing chat removes from chatlist
      await i.removeChat(chat1.id);
      dbUserChats = await i.findAllChats(dbUser.id);
      expect(dbUserChats.length, 1);

      i.removeUser(user1.id);
      dbUserChats = await i.findAllChats(user1.id);
      expect(dbUserChats, isNull);
    });

    test('Messages saving/finding/linking/deleting', () async {
      Message msg1 = Message(
          webId: '1',
          timestamp: DateTime.now(),
          contents: 'msg1');

      Message msg2 = Message(
          webId: '2',
          timestamp: DateTime.now(),
          contents: 'msg2');

      msg1.to.value = user1;
      msg1.from.value = user2;

      msg2.to.value = user2;
      msg2.from.value = user1;

      msg1.chat.value = chat1;
      msg2.chat.value = chat1;

      chat1.owners.add(user1);

      await i.saveMessage(msg1);
      await i.saveMessage(msg2);

      User? dbUser1 = await i.findUser(user1.id);
      User? dbUser2 = await i.findUser(user2.id);

      expect(dbUser1?.receivedMessages.length, 1);
      expect(dbUser2?.receivedMessages.length, 1);

      expect(dbUser1?.sentMessages.length, 1);
      expect(dbUser2?.sentMessages.length, 1);

      expect(dbUser1?.receivedMessages.first.id, msg1.id);
      expect(dbUser2?.receivedMessages.first.id, msg2.id);

      expect(dbUser1?.chats.first.id, chat1.id);
      expect(chat1.messages.length, 2);

      // Testing if messages get removed when chat is removed
      await i.removeChat(chat1.id);

      Chat? dbChat = await i.findChat(chat1.id);
      expect(dbChat, isNull);

      Message? dbMsg1 = await i.findMessage(msg1.id);
      Message? dbMsg2 = await i.findMessage(msg2.id);
      expect(dbMsg1, isNull);
      expect(dbMsg2, isNull);
    });


    test('findAllConnectedUsers working', () async {
      chat1.owners.add(user1);
      chat1.owners.add(user2);

      await i.saveChat(chat1);

      final list = await i.findAllConnectedUsers(user1.id);

      expect(list.length, 1);
    });


  });

}
