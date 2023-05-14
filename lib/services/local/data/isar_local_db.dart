import 'dart:async';
import 'package:cmtchat_app/collections/localservice_collection.dart';
import 'package:cmtchat_app/collections/local_models_collection.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


/// Isar local database service ///
// Implementation of all necessary operations for a data service
// as specified in the localDbApi abstract

class IsarLocalDb implements LocalDbApi {

  @override
  Future<int> saveUser(User user) async {
    final isar = await db;
    return isar.writeTxn(() async => await isar.users.put(user));
  }

  @override
  Future<User?> getUser(Id userId) async {
    final isar = await db;
    return await isar.users.get(userId);
  }


  /// Constructor
  // Automatically activates the database services when instantiated
  IsarLocalDb() { db = activate(); }

  // Database object used by this service
  late Future<Isar> db;



  @override
  Future<Stream<List<Message>>> chatMessageStream(Id chatId) async {
    final isar = await db;
    return isar.messages
        .filter()
        .chat((chat) => chat.idEqualTo(chatId))
        .watch(fireImmediately: true
    );
  }

  @override
  Future<Stream<List<Chat>>> allChatsUpdatedStream(Id userId) async {
    final isar = await db;
    await getAllUserChatsUpdated(userId);
    return isar.chats
        .filter()
        .owners((user) => user.idEqualTo(userId))
        .sortByLastUpdateDesc()
        .watch(fireImmediately: true
    );
  }

  @override
  Future<List<Chat>> getAllUserChatsUpdated(Id userId) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await getAllUserChats(userId)
          .then((list) async => {
        for(Chat chat in list) {
          await updateChatVariables(chat, userId),
          await isar.chats.put(chat),
        }
      });
    });
    return await getAllUserChats(userId);
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
    return await isar.writeTxnSync(() => isar.messages.putSync(message));
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
  @override
  Future<void> cleanDb() async {
    final isar = await db;
    isar.writeTxnSync(() async => isar.clearSync());
  }


}