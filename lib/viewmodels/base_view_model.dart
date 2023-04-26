import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/services/data/dataservice_contract.dart';

abstract class BaseViewModel {
  IDataService _dataService;

  BaseViewModel(this._dataService);

  Future<void> addMessage(Message message) async {
    if(!await _isExistingChat(message.message.webChatId!)) {
      await _createNewChat(message.message.webChatId!);
    }
    await _dataService.saveMessage(message);
  }

  Future<bool> _isExistingChat(String webChatId) async {
    return await _dataService.findWebChat(webChatId) != null;
  }

  Future<void> _createNewChat(String webChatId) async {
    final chat = Chat(webChatId: webChatId);
    await _dataService.saveChat(chat);
  }
}



