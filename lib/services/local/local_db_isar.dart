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
  Future<Chat?> findChatWith({
    required String ownerWebId,
    required String receiverWebId
  }) async {
    final isar = await _db;
    return isar.chats
        .filter()
        .ownerWebIdEqualTo(ownerWebId)
        .and()
        .receiverWebIdMatches(receiverWebId)
        .findFirstSync();
  }
  
  @override
  Future<Stream<List<Chat>>> allChatsStream({required int ownerId}) async {
    final isar = await _db;
    return isar.chats
        .filter()
        .owner((owner) => owner
        .idEqualTo(ownerId))
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
    isar.writeTxnSync(() {
      isar.users.putSync(chat.owner.value!);
      isar.chats.putSync(chat);
    });
  }

  @override
  Future<void> updateMessages({required List<Message> messages}) async {
    final chat = messages.first.chat.value!;
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.messages.putAll(messages);
      await isar.chats.put(chat);
    });
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

}