import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:flutter/foundation.dart';



abstract class BaseViewModel {
  final IDataService _dataService;
  final User _user;

  BaseViewModel(this._dataService, this._user);

  @protected
  Future<void> addMessage(WebMessage message, Chat chat, ReceiptStatus status) async {

    // Creating local representation of WebMessage
    final Message newMessage = Message(
        webId: message.webId,
        timestamp: message.timestamp,
        contents: message.contents,
        status: status,
        receiptTimestamp: DateTime.now());

    // Binding to sender and receiver
    final User to =
        await _dataService.findWebUser(message.to) ?? User(webUserId: message.to);
    final User from =
        await _dataService.findWebUser(message.to) ?? User(webUserId: message.to);
    newMessage.to.value = to;
    newMessage.from.value = from;

    // Binding to chat
    newMessage.chat.value = chat;

    // Saving the message should save new chats and/or users as well.
    await _dataService.saveMessage(newMessage);
  }

  Future<Chat> getChatWith(String webUserId) async {
    Chat? chat = await _dataService.findChatWith(webUserId);
    if(chat == null) {
      final user = User(webUserId: webUserId);
      chat = Chat();
      chat.owners.add(user);
      chat.owners.add(_user);
      _dataService.saveChat(chat);
    }
    return chat;
  }

}



