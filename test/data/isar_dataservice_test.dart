import 'dart:math';

import 'package:cmtchat_app/models/chats.dart';
import 'package:cmtchat_app/models/users.dart';
import 'package:cmtchat_app/services/data/isar/isar_dataservice.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_test.dart';


void main() {

  User user1 = User(newUsername: '123');
  Chat chat1 = Chat(chatName: 'test');

  group('Path_provider dependant tests', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await Isar.initializeIsarCore(download: true);
    });

    // Just to test since this has been a problem during development
    test('Testing that "getApplicationDocumentsDirectory()" is working', () async {
        var dir = await getApplicationDocumentsDirectory();
        expect(dir, isNotNull);
    });

    test('Add and retrieve a user to the db, then remove', () async {
      IsarService i = IsarService();

      await i.saveUser(user1);

      User? dbUser = await i.findUser(user1.id);

      expect(dbUser?.id, user1.id);
      expect(dbUser?.username, user1.username);

      await i.removeUser(user1.id);

      expect(await i.findUser(user1.id), isNull);
    });

    test('Add and retrieve a chat to the db, then remove', () async {
      IsarService i = IsarService();

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
      IsarService i = IsarService();

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

    test('Link multiple chats from user and checking backlink', () async {
      IsarService i = IsarService();

      Chat chat2 = Chat(chatName: "chat2");

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
      dbUserChats = await i.findAllChats(dbUser!.id);
      expect(dbUserChats?.length, 1);

      i.removeUser(user1.id);
      dbUserChats = await i.findAllChats(user1.id);
      expect(dbUserChats, isNull);
    });



  });

}
