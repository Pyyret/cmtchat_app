import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';

import 'package:sqflite/sqflite.dart';

import '../lib/services/local/data/dataservice_contract.dart';

class SqfliteService implements IDataService {
  final Database _db;

  const SqfliteService(this._db);

  @override
  Future<void> addChat(Chat chat) async {
    await _db.transaction((txn) async {
      await txn.insert('chats', chat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<void> addMessage(Message message) async {
    await _db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeChat(String chatId) async {
    final batch = _db.batch();
    batch.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() {
    return _db.transaction((txn) async {
      final listOfChatMaps = await txn.query(
          'chats',
          orderBy: 'updated_at DESC'
      );
      if (listOfChatMaps.isEmpty) return [];

      return await Future.wait(listOfChatMaps.map<Future<Chat>>((row) async {
        final unread = Sqflite.firstIntValue(
            await txn.rawQuery(
                'SELECT COUNT(*) FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
                [row['id'], 'delivered']));

        final mostRecentMessage = await txn.query(
            'messages',
            where: 'chat_id = ?',
            whereArgs: [row['id']],
            orderBy: 'created_at DESC',
            limit: 1);
        final chat = Chat.fromMap(row);
        chat.unread = unread!;
        if (mostRecentMessage.isNotEmpty) {
          chat.mostRecent = Message.fromMap(mostRecentMessage.first);
        }
        return chat;
      }));
    });
  }

  @override
  Future<Chat> findChat(String chatId) async {
    return await _db.transaction((txn) async {
      final listOfChatMaps = await txn.query(
          'chats',
          where: 'id = ?',
          whereArgs: [chatId]
      );

      final unread = Sqflite.firstIntValue(
          await txn.rawQuery(
              'SELECT COUNT(*) FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
              [chatId, 'delivered']
          )
      );

      final mostRecentMessage = await txn.query(
          'messages',
          where: 'chat_id = ?',
          whereArgs: [chatId],
          orderBy: 'created_at DESC',
          limit: 1
      );

      final chat = Chat.fromMap(listOfChatMaps.first);
      chat.unread = unread!;
      chat.mostRecent = Message.fromMap(mostRecentMessage.first);

      return chat;
    });
  }

  @override
  Future<List<Message>> findMessage(String chatId) async {
    final listOfMessageMaps = await _db.query(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [chatId]
    );

    return listOfMessageMaps
        .map<Message>((map) => Message.fromMap(map))
        .toList();
  }

  Future<void> updateMessage(Message message) async {
    await _db.update(
        'messages',
        message.toMap(),
        where: 'id = ?',
        whereArgs: [message.message.id],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

    @override
    Future<void> updateMessageReceipt(String messageId, ReceiptStatus status) {
      return _db.transaction((txn) async {
        await txn.update(
            'messages',
            {'receipt': status.value()},
            where: 'id = ?',
            whereArgs: [messageId],
            conflictAlgorithm: ConflictAlgorithm.replace
        );
      });
  }

  @override
  Future<void> removeUser(User user) {
    // TODO: implement removeUser
    throw UnimplementedError();
  }

  @override
  Future<int> saveChat(Chat c) {
    // TODO: implement saveChat
    throw UnimplementedError();
  }

  @override
  Future<void> saveMessage(Message message) {
    // TODO: implement saveMessage
    throw UnimplementedError();
  }

  @override
  Future<void> saveUser(User user) {
    // TODO: implement saveUser
    throw UnimplementedError();
  }
}