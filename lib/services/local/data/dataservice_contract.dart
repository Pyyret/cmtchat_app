import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';

/// Interface for any form of local storage of chats & messages
abstract class IDataService {

  /// User
  Future<void> saveUser(User user);
  Future<User?> findUser(int userId);
  Future<void> removeUser(int userId);

  /// Chat
  Future<void> saveChat(Chat chat);
  Future<Chat?> findChat(int chatId);
  Future<Chat?> findWebChat(String webChatId);
  Future<List<Chat>?> findAllChats(int userId);
  Future<void> removeChat(int chatId);

  /// LocalMessage
  Future<void> saveMessage(Message message);
  Future<Message?> findMessage(int messageId);
  Future<List<Message>?> findAllMessages(int chatId);
  Future<void> removeMessage(int messageId);
  //Future<void> updateMessageReceipt(String messageId, ReceiptStatus status);
}