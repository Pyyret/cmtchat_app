import 'dart:async';

import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'dataservice_contract.dart';



/// Isar local database service ///
// Implementation of all necessary operations for a dataservice
// as specified in the dataservice contract, IDataService

class IsarService implements IDataService {

  // Database object used by this service
  late Future<Isar> db;

  /// Constructor
  // Automatically activates the database services when instantiated
  IsarService() { db = activate(); }


/// Override methods ///

  /// User
  @override
  Future<void> saveUser(User user) async {
    final isar = await db;
     isar.writeTxnSync(() => isar.users.putSync(user));
  }

  @override
  Future<User?> findUser(Id userId) async {
    final isar = await db;
    return await isar.users.get(userId);
  }

  @override
  Future<User?> findWebUser(String webId) async {
    final isar = await db;
    final list = isar.users
        .filter()
        .webUserIdEqualTo(webId)
        .findAllSync();
    if(list.isEmpty) { return null; }
    else { return list.single; }
  }

  @override
  Future<void> removeUser(Id userId) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.users.deleteSync(userId));
  }


  /// Chat

  // Returns the id of the new or updated chat
  @override
  Future<void> saveChat(Chat chat) async {
    final isar = await db;
    return isar.writeTxnSync(() => isar.chats.putSync(chat));
  }

  @override
  Future<Chat?> findChat(Id chatId) async {
    final isar = await db;
    return isar.chats.get(chatId);
    //Dont know why it wont WORK!!
    /*
    final isar = await db;
    await isar.writeTxn(() async {
      final chat = await isar.chats.get(chatId);
      chat?.unread = isar.localMessages
          .filter()
          .chat((q) => q.idEqualTo(chatId))
          .and()
          .receipt((q) => q.statusEqualTo(ReceiptStatus.delivered))
          .findAllSync()
          .length;
      await isar.chats.put(chat!);
    });
    return isar.chats.get(chatId);

     */
  }

  @override
  Future<Chat?> findChatWith(String webUserId) async {
    final isar = await db;
    final list = isar.chats
        .filter()
        .owners((user) => user.webUserIdEqualTo(webUserId))
        .findAllSync();
    if(list.isEmpty) { return null; }
    else { return list.single; }
  }

  @override
  Future<List<Chat>?> findAllChats(Id userId) async {
    final isar = await db;
    final user = await isar.users.get(userId);
    return user?.chats.toList();
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


  /// Message

  @override
  Future<void> saveMessage(Message message) async {
    final isar = await db;
    return isar.writeTxnSync(() => isar.messages.putSync(message));
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
  Future<void> removeMessage(int messageId) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.messages.deleteSync(messageId));
  }


  /// Activate and open the local isar database for use ///
  // This is called everytime a new instance of this service class is made
  Future<Isar> activate() async {
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

  /// Clear the entire database -- BE CAREFUL ///
  Future<void> cleanDb() async {
    final isar = await db;
    isar.writeTxnSync(() => isar.clearSync());
  }
}