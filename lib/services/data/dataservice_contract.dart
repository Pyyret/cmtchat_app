

import 'package:cmtchat_app/models/local/chats.dart';
import 'package:cmtchat_app/models/local/messages.dart';
import 'package:cmtchat_app/models/local/users.dart';

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
  Future<void> saveMessage(LocalMessage message);
  Future<LocalMessage?> findMessage(int messageId);
  Future<List<LocalMessage>?> findAllMessages(int chatId);
  Future<void> removeMessage(int messageId);
  //Future<void> updateMessageReceipt(String messageId, ReceiptStatus status);
}