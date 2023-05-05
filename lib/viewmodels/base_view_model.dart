import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:flutter/foundation.dart';



abstract class BaseViewModel {
  final IDataService _dataService;
  final User _mainUser;

  BaseViewModel(this._dataService, this._mainUser);

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
    User? to = await _dataService.findWebUser(message.to);
    to ??= User(webUserId: message.to);
    User? from = await _dataService.findWebUser(message.from);
    from ??= User(webUserId: message.from);
    newMessage.to.value = to;
    newMessage.from.value = from;

    // Updating chat
    //chat.unread++;
    //await _dataService.saveChat(chat);

    // Binding to chat
    newMessage.chat.value = chat;

    // Saving the message should save new chats and/or users as well.
    await _dataService.saveMessage(newMessage);
  }

  Future<Chat> getChatWith(String webUserId) async {
    Chat? chat = await _dataService.findChatWith(webUserId);
    if(chat == null) {
      User? chatMate = await _dataService.findWebUser(webUserId);
      chatMate ??= User(webUserId: webUserId);
      chat = Chat(chatName: chatMate.username);
      chat.owners.add(chatMate);
      chat.owners.add(_mainUser);
      await _dataService.saveChat(chat);
    }
    return chat;
  }



}



