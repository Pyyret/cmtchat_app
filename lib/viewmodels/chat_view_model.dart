import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/receipt.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/viewmodels/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  final IDataService _dataService;
  final User _user;
  Chat? thisChat;
  int otherMessages = 0;

  ChatViewModel(this._dataService, this._user) : super(_dataService, _user);

  Future<List<Message>> getMessages(Chat chat) async {
    Chat? updatedChat = await _dataService.findChat(chat.id);
    if(updatedChat == null) { return <Message>[]; }
    return updatedChat.messages.toList();
  }

  Future<void> sentMessage(WebMessage message) async {
    thisChat ??= await getChatWith(message.to);
    await addMessage(message, thisChat!, ReceiptStatus.sent);
  }

  Future<void> receivedMessage(WebMessage message) async {
  final chat = await getChatWith(message.from);
  if(chat.id != thisChat?.id) { otherMessages++; }
  await addMessage(message, chat, ReceiptStatus.delivered);
}

  Future<void> updateMessageReceipt(Receipt receipt) async {
    await _dataService.updateMessageReceipt(receipt.messageId, receipt);
  }

}