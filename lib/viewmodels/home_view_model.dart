import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/services/local/data/local_db_api.dart';
import 'package:cmtchat_app/views/home/shared_blocs/receipt_bloc/receipt_bloc.dart';
import 'package:isar/isar.dart';

import '../collections/user_webuser_service_collection.dart';


class HomeViewModel {
  final LocalDbApi _dataService;
  final WebUserServiceApi _webUserService;
  final ReceiptBloc _receiptBloc;

  late User _user;

  HomeViewModel(this._dataService, this._webUserService, this._receiptBloc);

  void setUser(User user) => _user = user;

  // Called whenever a new message is received in the UI-page 'chats'
  Future<void> receivedMessage(WebMessage message) async {
    final chat = await getChatWith(message.from);
    await addMessage(message, chat!, ReceiptStatus.delivered);
  }

  Future<Chat?> getChatWith(String webUserId) async {
    Chat chat = await _dataService.findChatWith(webUserId) ?? Chat();
    User chatMate = await _dataService.findWebUser(webUserId)
        ?? User(webUserId: webUserId);
    chat.owners.add(chatMate);
    chat.owners.add(_user);
    int newChatId = await _dataService.saveChat(chat, _user.id);

    return await _dataService.findChat(newChatId);
  }

  Future<void> addMessage(WebMessage message, Chat chat, ReceiptStatus status) async {

    // Creating local representation of WebMessage
    final Message newMessage = Message(
        webId: message.webId,
        timestamp: message.timestamp,
        contents: message.contents,
        status: status,
        receiptTimestamp: DateTime.now());

    // Binding to sender and receiver
    User? to = await _dataService.findWebUser(message.to);
    to ??= User(webUserId: message.to);
    User? from = await _dataService.findWebUser(message.from);
    from ??= User(webUserId: message.from);
    newMessage.to.value = to;
    newMessage.from.value = from;

    // Binding to chat
    newMessage.chat.value = chat;

    // Saving the message should save new chats and/or users as well.
    await _dataService.saveMessage(newMessage);
  }


  Future<List<WebUser>> activeUsers() async {
    final activeUserList = await _webUserService.online();
    activeUserList.removeWhere((user) => user.webUserId == _user.webUserId);
    return activeUserList;
  }






  // Update relevant local users with information from the webserver.
  _syncWebUsers() async {
    final usersWebIdList = await getConnectedUsersWebIdList();
    // Get a list of updated webUsers from webServer
    final updatedWebUsers = await _webUserService.fetch(usersWebIdList);

    // Update each local user with the updated webUser data
    for(WebUser webUser in updatedWebUsers) {
      final user = await _dataService.findWebUser(webUser.webUserId!);
      user!.update(webUser);
      await _dataService.saveUser(user);
    }
  }

  // Creates a list of all relevant users webId
  Future<List<String>> getConnectedUsersWebIdList() async {
    List<String> usersWebIdList = List<String>.empty(growable: true);
    final connectedUsers = await _dataService.findAllConnectedUsers(_user.id);
    for (User user in connectedUsers) {
      usersWebIdList.add(user.webUserId!);
    }
    return usersWebIdList;
  }
}