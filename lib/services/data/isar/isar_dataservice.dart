import 'dart:async';

import 'package:cmtchat_app/models/chats.dart';
import 'package:cmtchat_app/models/messages.dart';
import 'package:cmtchat_app/models/users.dart';
import 'package:cmtchat_app/services/data/dataservice_contract.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';



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
    return await isar.chats.get(chatId);
  }

  @override
  Future<List<Chat>?> findAllChats(Id userId) async {
    final isar = await db;
    final user = await isar.users.get(userId);
    return user?.allChats.toList();
  }

  // Also removes all messages linked to the chat.
  @override
  Future<void> removeChat(Id chatId) async {
    final isar = await db;
    isar.writeTxnSync(() async {
      isar.localMessages
          .filter()
          .chat((q) => q.idEqualTo(chatId))
          .deleteAllSync();
      isar.chats.deleteSync(chatId);
    });
  }


  /// Message

  @override
  Future<void> saveMessage(LocalMessage message) async {
    final isar = await db;
    return isar.writeTxnSync(() => isar.localMessages.putSync(message));
  }

  @override
  Future<LocalMessage?> findMessage(int messageId) async {
    final isar = await db;
    return await isar.localMessages.get(messageId);
  }

  @override
  Future<List<LocalMessage>?> findAllMessages(int chatId) async {
    final isar = await db;
    final chat = await isar.chats.get(chatId);
    return chat?.allMessages.toList();
  }

  @override
  Future<void> removeMessage(int messageId) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.localMessages.deleteSync(messageId));
  }


  /// Activate and open the local isar database for use ///
  // This is called everytime a new instance of this service class is made
  Future<Isar> activate() async {
    if (Isar.instanceNames.isEmpty) {
      var dir = await getApplicationDocumentsDirectory();
      return await Isar.open([
        UserSchema,
        ChatSchema,
        LocalMessageSchema
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