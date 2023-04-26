import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';
import 'package:cmtchat_app/viewmodels/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  IDataService _dataService;
  User _user;
  Chat? thisChat;
  int otherMessages = 0;

  ChatViewModel(this._dataService, this._user) : super(_dataService,_user);

  Future<List<Message>> getMessages(String webUserId) async {
    List<Message> messages;
    Chat? chat = await _dataService.findChatWith(webUserId);
    if(chat == null) { messages = <Message>[]; }
    else {
      chat = chat;
      messages = chat.messages.toList();
    }
    return messages;
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

}