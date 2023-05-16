import 'package:cmtchat_app/collections/models_local.dart';

/// Interface ///
abstract class LocalDbApi {
  /// Db
  Future<void> cleanDb();

  /// User
  Future<User?> getUser({required int userId});
  Future<User> putUser({required User user});

  /// Chat
  Future<Chat> saveNewChat({
    required User owner, required User receiver, Message? message
  });
  Future<Chat?> findChatWithWebId({required String userWebId});
  Future<Stream<List<Chat>>> allChatsStream();

  /// Message
  Future<void> saveReceivedMessage({required Chat chat, required Message message});
  Future<void> saveSentMessage({required Chat chat, required Message message});
  Future<void> updateMessages({required List<Message> msgList});
  Future<Message?> findMessageWith({required String webId});
  Future<Stream<List<Message>>> chatMessageStream(int chatId);
}