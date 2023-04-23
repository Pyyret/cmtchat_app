import '../../models/chats.dart';
import '../../models/messages.dart';
import '../../models/users.dart';

/// Interface for any form of local storage of chats & messages
abstract class IDataService {

  /// User
  Future<void> saveUser(User user);
  Future<User?> findUser(int userId);
  Future<void> removeUser(int userId);

  /// Chat
  Future<void> saveChat(Chat chat);
  Future<Chat?> findChat(int chatId);
  Future<List<Chat>?> findAllChats(int userId);
  Future<void> removeChat(int chatId);

  /// LocalMessage
  Future<void> saveMessage(LocalMessage message);
  Future<List<LocalMessage>> findMessage(String messageId);
  Future<void> updateMessage(LocalMessage message);
  //Future<void> updateMessageReceipt(String messageId, ReceiptStatus status);
}