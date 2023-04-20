import 'dart:async';

import 'package:cmtchat_app/models/chat.dart';
import 'package:cmtchat_app/models/local_message.dart';
import 'package:cmtchat_app/services/data/dataservice_contract.dart';
import 'package:cmtchat_backend/src/models/receipt.dart';
import 'package:cmtchat_backend/src/models/user.dart';
import 'package:isar/isar.dart';
import  'collections.dart' show ChatSchema, GetChatCollection, LocalMessageSchema, ReceiptSchema, TypingEventSchema, UserSchema;
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
  Future<void> saveUser(User user) {
    // TODO: implement saveUser
    throw UnimplementedError();
  }

  @override
  Future<void> removeUser(User user) {
    // TODO: implement removeUser
    throw UnimplementedError();
  }


  /// Chat

  // Returns the id of the new or updated chat
  @override
  Future<int> saveChat(Chat chat) async {
    final isar = await db;
    return isar.writeTxnSync<int>(() => isar.chats.putSync(chat));
  }

  @override
  Future<void> deleteChat(String chatId) {
    // TODO: implement deleteChat
    throw UnimplementedError();
  }

  @override
  Future<List<Chat>> findAllChats() {
    // TODO: implement findAllChats
    throw UnimplementedError();
  }

  @override
  Future<Chat> findChat(String chatId) {
    // TODO: implement findChat
    throw UnimplementedError();
  }


  /// LocalMessage
  @override
  Future<List<LocalMessage>> findMessage(String messageId) {
    // TODO: implement findMessage
    throw UnimplementedError();
  }

  @override
  Future<void> saveMessage(LocalMessage message) {
    // TODO: implement saveMessage
    throw UnimplementedError();
  }

  @override
  Future<void> updateMessage(LocalMessage message) {
    // TODO: implement updateMessage
    throw UnimplementedError();
  }

  @override
  Future<void> updateMessageReceipt(String messageId, ReceiptStatus status) {
    // TODO: implement updateMessageReceipt
    throw UnimplementedError();
  }



  /// Activate and open the local database for use ///
  // This is called everytime a new instance of this service class is made
  Future<Isar> activate() async {
    if (Isar.instanceNames.isEmpty) {
      var dir = await getApplicationDocumentsDirectory();
      return await Isar.open([
        ChatSchema,
        LocalMessageSchema,
        ReceiptSchema,
        TypingEventSchema,
        UserSchema
      ], inspector: true, directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }
}