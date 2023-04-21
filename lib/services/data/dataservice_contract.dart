import '../../models/chats.dart';
import '../../models/messages.dart';
import '../../models/users.dart';

/// Interface for any form of local storage of chats & messages
abstract class IDataService {

  /// User
  Future<void> saveUser(User user);
  Future<void> removeUser(User user);

  /// Chat
  Future<int> saveChat(Chat chat);
  Future<List<Chat>> findAllChats();
  Future<Chat> findChat(String chatId);
  Future<void> deleteChat(String chatId);

  /// LocalMessage
  Future<void> saveMessage(LocalMessage message);
  Future<List<LocalMessage>> findMessage(String messageId);
  Future<void> updateMessage(LocalMessage message);
  //Future<void> updateMessageReceipt(String messageId, ReceiptStatus status);
}