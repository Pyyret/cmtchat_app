import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/viewmodels/base_view_model.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';


class ChatsViewModel extends BaseViewModel {
  IDataService _dataService;
  final User _user;

  ChatsViewModel(this._dataService, this._user) : super(_dataService, _user);

  Future<List<Chat>> getChats() async =>
      await _dataService.findAllChats(_user.id) ?? <Chat>[];

  Future<void> receivedMessage(WebMessage message) async {
    final chat = await getChatWith(message.from);
    await addMessage(message, chat, ReceiptStatus.delivered);
  }

}