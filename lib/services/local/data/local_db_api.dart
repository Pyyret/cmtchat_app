import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';

/// Interface for any form of local storage of chats & messages
abstract class LocalDbApi {

  Future<Stream<List<Message>>> chatMessageStream(int chatId);

  /// User
  Future<User?> getUser({required int userId});
  Future<User> putUser({required User user});
  //Future<User?> findUser({required int userId});
  //Future<User> getUserFrom({required String webId});
  //Future<List<User>> findAllConnectedUsers({required int userId});
  //Future<bool> removeUser({required int userId});

  /// Chat
  Future<Chat> saveNewChat({
    required Chat chat,
    required User owner,
    required User receiver,
    Message? message});
  //Future<Chat> updateChat({required Chat initializedChat});
  //Future<Chat> getChatWith({int receiverId});
  Future<Chat?> findChatWithWebUser({required String webUserId});
  //Future<Chat?> findChat(int chatId);
  //Future<List<Chat>> getAllUserChatsUpdated(int userId);
  //Future<List<Chat>> getAllUserChats(int userId);
  Future<Stream<List<Chat>>> allChatsStream();
  //Future<Chat> updateChatVariables({Chat chat});
  //Future<Chat> updateAllChatVariables({Chat chat});

  //Future<void> removeChat(int chatId);

  /// Message
  Future<void> saveReceivedMessage({required Chat chat, required Message message});

  //Future<Message?> findMessage(int messageId);
  //Future<List<Message>?> findAllMessages(int chatId);
  //Future<void> removeMessage(int messageId);
  //Future<void> updateMessageReceipt(String messageId, Receipt receipt);

  Future<void> cleanDb();


}