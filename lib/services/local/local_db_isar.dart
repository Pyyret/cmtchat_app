import 'dart:async';


import 'package:cmtchat_app/collections/models_local.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/services/local/local_db_api.dart';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';



/// Isar local database service ///
// Implementation of all necessary operations for a data service
// as specified in the localDbApi abstract
class LocalDbIsar implements LocalDbApi {
  /// Private Database Object
  late Future<Isar> _db;

  /// Constructor
  // Automatically activates the database services when instantiated
  LocalDbIsar() { _db = _activate(); }


  /// Methods ///

  /// Caution! - Clears the entire database
  @override
  Future<void> cleanDb() async {
    final isar = await _db;
    isar.writeTxnSync(() async => isar.clearSync());
  }

  /// User
  @override
  Future<User> putUser({required User user}) async {
    final isar = await _db;
    user.id = await isar.writeTxn(() async => await isar.users.put(user));
    return user;
  }

  @override
  Future<User?> getUser({required Id userId}) async {
    final isar = await _db;
    return await isar.users.get(userId);
  }

  /// Chat
  @override
  Future<Chat> saveNewChat({
    required User owner, required User receiver, Message? message}) async {
    final chat = Chat()
      ..owner.value = owner
      ..receiver.value = receiver
      ..chatName = receiver.username;
    if(message != null) { _setReceivedMessageVariables(chat, message); }

    final isar = await _db;
    final savedChatId = await isar.writeTxn(() async {
      await isar.users.put(receiver);
      await isar.chats.put(chat);
      if(message != null) {
        await isar.messages.put(message);
        await message.chat.save();
        await message.to.save();
        await message.from.save();
      }
      await chat.receiver.save();
      await chat.owner.save();
      final savedChat = await _updateChatVariables(chat: chat);
      return await isar.chats.put(savedChat);
    });
    return isar.chats.get(savedChatId).then((chat) => chat!);
  }

  @override
  Future<Chat?> findChatWithWebId({required String userWebId}) async {
    final isar = await _db;
    return isar.chats
        .filter()
        .receiver((receiver) => receiver.webIdEqualTo(userWebId))
        .findAll()
        .then((list) {
      if(list.isEmpty) { return null; }
      else { return list.single; }
    });
  }

  @override
  Future<Stream<List<Chat>>> allChatsStream() async {
    final isar = await _db;
    await _updateAllChatsVariables();
    return isar.chats
        .where()
        .sortByLastUpdateDesc()
        .watch(fireImmediately: true);
  }


  /// Message
  @override
  Future<void> saveReceivedMessage({required Chat chat, required Message message})
  async {
    _setReceivedMessageVariables(chat, message);
    await _writeNewMessage(chat, message);
  }

  @override
  Future<void> saveSentMessage({required Chat chat, required Message message})
  async {
    message.chat.value = chat;
    message.to.value = chat.receiver.value;
    message.from.value = chat.owner.value;
    await _writeNewMessage(chat, message);
  }

  @override
  Future<void> updateMessages({required List<Message> msgList}) async {
    final chat = msgList.first.chat.value!;
    final isar = await _db;
    await isar.writeTxn(() async {
      for (Message msg in msgList) {
        await isar.messages.put(msg);
      }
      final updatedChat = await _updateChatVariables(chat: chat);
      await isar.chats.put(updatedChat);
    });
  }

  @override
  Future<Message?> findMessageWith({required String webId}) async {
    final isar = await _db;
    return isar.messages
        .filter()
        .webIdEqualTo(webId)
        .findFirstSync();
  }

  @override
  Future<Stream<List<Message>>> chatMessageStream(Id chatId) async {
    final isar = await _db;
    return isar.messages
        .filter()
        .chat((chat) => chat.idEqualTo(chatId))
        .watch(fireImmediately: true);
  }


  /// Private Methods ///

  /// Chat
  Future<void> _updateAllChatsVariables() async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.chats
          .where()
          .findAll()
          .then((list) async {
        for(Chat chat in list) {
          await _updateChatVariables(chat: chat);
          await isar.chats.put(chat);
        }
      });
    });
  }

  Future<Chat> _updateChatVariables({required Chat chat})
  async {
    chat.unread = await chat.messages
        .filter()
        .statusEqualTo(ReceiptStatus.delivered)
        .count();
    await chat.messages
        .filter()
        .sortByTimestampDesc()
        .findFirst()
        .then((message) {
      if(message != null) {
        chat.lastUpdate = message.timestamp;
        chat.lastMessageContents = message.contents; }
    });
    return chat;
  }

  /// Message
  void _setReceivedMessageVariables(Chat chat, Message message) {
    message.chat.value = chat;
    message.to.value = chat.owner.value;
    message.from.value = chat.receiver.value;
  }

  Future<void> _writeNewMessage(Chat chat, Message message) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.messages.put(message);
      await message.chat.save();
      await message.to.save();
      await message.from.save();
      final updatedChat = await _updateChatVariables(chat: chat);
      await isar.chats.put(updatedChat);
    });
  }

  /// Isar
  // Activates and opens the local isar database for use
  Future<Isar> _activate() async {
    if (Isar.instanceNames.isEmpty) {
      var dir = await getApplicationDocumentsDirectory();
      return await Isar.open([
        UserSchema,
        ChatSchema,
        MessageSchema
      ], directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }

  /// ///////////////////////////////////////////////////////

  /*

  @override
  Future<List<Chat>> getAllUserChats(Id userId) async {
    final isar = await db;
    return isar.chats
        .filter()
        .owners((user) => user.idEqualTo(userId))
        .findAll();
  }


  @override
  Future<Chat> updateChatVariables(Chat chat, Id userId) async {
    chat.unread = await chat.messages
        .filter()
        .statusEqualTo(ReceiptStatus.delivered)
        .findAll()
        .then((list) => list.length);

    await chat.messages
        .filter()
        .sortByTimestampDesc()
        .findFirst().then((message) {
      if(message != null) {
        chat.lastUpdate = message.timestamp ?? DateTime.parse('0000-01-01');
        chat.lastMessageContents = message.contents;
      }
    });

    chat.chatName = await chat.owners
        .filter()
        .not()
        .idEqualTo(userId)
        .findFirst()
        .then((user) => user?.username) ?? 'unnamed';

    return chat;
  }



  /// User methods ///


  @override
  Future<User?> findWebUser(String webUserId) async {
    final isar = await db;
    final list = isar.users
        .filter()
        .webUserIdEqualTo(webUserId)
        .findAllSync();
    if(list.isEmpty) { return null; }
    else { return list.single; }
  }

  @override
  Future<List<User>> findAllConnectedUsers(Id userId)  async {
    final isar = await db;
    return isar.users
        .filter()
        .chats((chat) => chat.owners((owner) => owner.idEqualTo(userId)))
        .not()
        .idEqualTo(userId)
        .findAllSync()
        .toList();
  }

  @override
  Future<void> removeUser(Id userId) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.users.deleteSync(userId));
  }


  /// Chat

  // Returns the id of the new or updated chat
  @override
  Future<Chat> saveChat(Chat chat, Id userId) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.chats.putSync(chat));
    await updateChatVariables(chat, userId);
    final newChatId = isar.writeTxnSync(() => isar.chats.putSync(chat));
    return isar.chats.getSync(newChatId)!;
  }

  @override
  Future<Chat?> findChat(Id chatId) async {
    final isar = await db;
    return await isar.chats.get(chatId);
  }


  @override
  Future<Stream<Chat?>> chatUpdateStream(Id chatId) async {
    final isar = await db;
    return isar.chats.watchObject(chatId, fireImmediately: true);
  }



  // Also removes all messages linked to the chat.
  @override
  Future<void> removeChat(Id chatId) async {
    final isar = await db;
    isar.writeTxnSync(() async {
      isar.messages
          .filter()
          .chat((q) => q.idEqualTo(chatId))
          .deleteAllSync();
      isar.chats.deleteSync(chatId);
    });
  }




  @override
  Future<Message?> findMessage(int messageId) async {
    final isar = await db;
    return await isar.messages.get(messageId);
  }

  @override
  Future<List<Message>?> findAllMessages(int chatId) async {
    final isar = await db;
    final chat = await isar.chats.get(chatId);
    return chat?.messages.toList();
  }

  @override
  Future<void> updateMessageReceipt(String messageWebId, Receipt receipt) async {
    final isar = await db;
    final message = isar.messages.filter().webIdEqualTo(messageWebId).findAllSync().single;
    message.status = receipt.status;
    message.receiptTimestamp = receipt.timestamp;
    await isar.writeTxn(() => isar.messages.put(message));
  }

  @override
  Future<void> removeMessage(int messageId) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.messages.deleteSync(messageId));
  }



   */


}