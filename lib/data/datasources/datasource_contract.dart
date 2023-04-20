import 'package:cmtchat_backend/cmtchat_backend.dart';

import '../../models/chat.dart';
import '../../models/local_message.dart';

/// Interface for any form of local storage of chats & messages
abstract class IDatasource {
  Future<void> addChat(Chat chat);
  Future<void> addMessage(LocalMessage message);
  Future<void> deleteChat(String chatId);
  Future<List<Chat>> findAllChats();
  Future<Chat> findChat(String chatId);
  Future<List<LocalMessage>> findMessage(String chatId);
  Future<void> updateMessage(LocalMessage message);
  Future<void> updateMessageReceipt(String messageId, ReceiptStatus status);
}