import 'dart:async';

import 'package:cmtchat_app/collections/models.dart';

import 'package:cmtchat_app/services/local/local_db_api.dart';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


/// Isar local database service ///
// Implementation of all necessary operations for a data service
// as specified in the localDbApi abstract
class LocalDbIsar implements LocalDbApi {

  /// Constructor
  // Automatically activates the database services when instantiated
  LocalDbIsar() { _db = _activate(); }

  /// Private database instance variable
  late Future<Isar> _db;

  /// Methods ///
  @override               /// Caution! - This deletes everything in the database
  Future<void> cleanDb() async {
    final isar = await _db;
    isar.writeTxnSync(() async => isar.clearSync());
  }

  /// User ///
  @override
  Future<int> putUser(User user) async {
    final isar = await _db;
    return await isar.writeTxnSync(() async => isar.users.putSync(user));
  }

  @override
  Future<User?> findUser({required Id userId}) async {
    final isar = await _db;
    return await isar.users.get(userId);
  }

  @override
  Future<User?> findUserWith({required String username}) async {
    final isar = await _db;
    return isar.users.filter().usernameEqualTo(username).findFirstSync();
  }

  /// Chat ///
  @override
  Future<void> saveNewChat({required Chat chat, required User owner}) async {
    final isar = await _db;
    chat.owner.value = owner;
    isar.writeTxnSync(() => isar.chats.putSync(chat));
  }
  
  @override
  Future<Chat?> findChatWithWebId({required String userWebId}) async {
    final isar = await _db;
    return isar.chats.filter().receiverWebIdMatches(userWebId).findFirstSync();
  }
  
  @override
  Future<Stream<List<Chat>>> allChatsStream({required int ownerId}) async {
    final isar = await _db;
    return isar.chats
        .filter()
        .owner((owner) => owner.idEqualTo(ownerId))
        .watch(fireImmediately: true);
  }
  
  /// Message

  @override
  Future<void> saveMessage({required Chat chat, required Message message})
  async {
    final isar = await _db;
    message.toWebId == chat.ownerWebId
        ? chat.owner.value?.receivedMessages.add(message)
        : chat.owner.value?.sentMessages.add(message);
    chat.messages.add(message);
    isar.writeTxnSync(() => isar.messages.putSync(message));
  }

  @override
  Future<void> updateMessages({required List<Message> messages}) async {
    final isar = await _db;
    await isar.writeTxn(() async { isar.messages.putAll(messages); });
  }

  @override
  Future<Message?> findMessageFrom({required String webId}) async {
    final isar = await _db;
    return isar.messages.filter().webIdEqualTo(webId).findAllSync().single;
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