import 'package:cmtchat_app/models/local/chats.dart';
import 'package:cmtchat_app/models/local/messages.dart';
import 'package:cmtchat_app/models/local/users.dart';
import 'package:cmtchat_app/services/data/isar/isar_dataservice.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_mock_classes.dart';


Future<void> main() async {
  PathProviderPlatform.instance = FakePathProviderPlatform();
  await Isar.initializeIsarCore(download: true);

  final IsarService i = IsarService();

  User user1 = User(newUsername: '111');
  User user2 = User(newUsername: '222');
  Chat chat1 = Chat(chatName: 'chat1');
  Chat chat2 = Chat(chatName: 'chat2');

  group('Path_provider dependant tests', () {

    setUp(() async {
      user1 = User(newUsername: '123');
      user2 = User(newUsername: '222');
      chat1 = Chat(chatName: 'test');
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
      chat1.owner.value = user1;
      await i.saveChat(chat1);

      Chat? dbChat = await i.findChat(chat1.id);
      User? chatOwner = dbChat?.owner.value;

      expect(chatOwner, isNotNull);
      expect(chatOwner?.id, user1.id);
      expect(chatOwner?.username, '123');

      // Testing that backlink works
      User? dbUser = await i.findUser(user1.id);
      Chat? user1Chats = dbUser?.allChats.first;

      expect(user1Chats, isNotNull);
      expect(user1Chats?.id, chat1.id);
    });

    test('Link multiple chats to user and checking backlink', () async {
      user1.allChats.add(chat1);
      user1.allChats.add(chat2);

      await i.saveUser(user1);

      User? dbUser = await i.findUser(user1.id);
      List<Chat>? dbUserChats = await i.findAllChats(dbUser!.id);

      expect(dbUserChats, isNotNull);
      expect(dbUserChats?.length, 2);

      // Here testing that backlink works also
      expect(dbUserChats?.first.owner.value?.id, user1.id);

      // Test that removing chat removes from chatlist
      await i.removeChat(chat1.id);
      dbUserChats = await i.findAllChats(dbUser.id);
      expect(dbUserChats?.length, 1);

      i.removeUser(user1.id);
      dbUserChats = await i.findAllChats(user1.id);
      expect(dbUserChats, isNull);
    });

    test('Messages saving/finding/linking/deleting', () async {
      LocalMessage msg1 = LocalMessage(
          message: Message(
              timestamp: DateTime.now(),
              contents: 'msg1'));
      LocalMessage msg2 = LocalMessage(
          message: Message(
              timestamp: DateTime.now(),
              contents: 'msg1'));

      msg1.isarTo.value = user1;
      msg1.isarFrom.value = user2;

      msg2.isarTo.value = user2;
      msg2.isarFrom.value = user1;

      msg1.chat.value = chat1;
      msg2.chat.value = chat1;

      chat1.owner.value = user1;

      await i.saveMessage(msg1);
      await i.saveMessage(msg2);

      User? dbUser1 = await i.findUser(user1.id);
      User? dbUser2 = await i.findUser(user2.id);

      expect(dbUser1?.allReceivedMessages.length, 1);
      expect(dbUser2?.allReceivedMessages.length, 1);

      expect(dbUser1?.allSentMessages.length, 1);
      expect(dbUser2?.allSentMessages.length, 1);

      expect(dbUser1?.allReceivedMessages.first.id, msg1.id);
      expect(dbUser2?.allReceivedMessages.first.id, msg2.id);

      expect(dbUser1?.allChats.first.id, chat1.id);
      expect(chat1.allMessages.length, 2);

      // Testing if messages get removed when chat is removed
      await i.removeChat(chat1.id);

      Chat? dbChat = await i.findChat(chat1.id);
      expect(dbChat, isNull);

      LocalMessage? dbMsg1 = await i.findMessage(msg1.id);
      LocalMessage? dbMsg2 = await i.findMessage(msg2.id);
      expect(dbMsg1, isNull);
      expect(dbMsg2, isNull);
    });

    test('findWebChat() test!', () => null);

  });

}
