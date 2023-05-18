import 'package:cmtchat_app/collections/models_local.dart';

/// Interface ///
abstract class LocalDbApi {
  /// Db
  Future<void> cleanDb();

  /// User
  Future<User?> findUser({required int userId});
  Future<User?> findUserWith({required String username});
  Future<int> putUser(User user);

  /// Chat
  Future<void> saveNewChat({required Chat chat, required User owner});
  Future<Chat?> findChatWith({required String webUserId});
  Future<Stream<List<Chat>>> allChatsStream({required int ownerId});

  /// Message
  Future<void> saveMessage({required Chat chat, required Message message});
  Future<void> updateMessages({required List<Message> messages});
  Future<Message?> findMessageFrom({required String webId});
  Future<Stream<List<Message>>> chatMessageStream(int chatId);
}