import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/user/web_user_service_contract.dart';
import 'package:cmtchat_app/viewmodels/base_view_model.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';


class ChatsViewModel extends BaseViewModel {
  final IDataService _dataService;
  final IWebUserService _webUserService;
  final User _user;

  ChatsViewModel(this._dataService, this._webUserService, this._user)
      : super(_dataService, _user);

  // Returns a WebUser representation of '_user'
  WebUser getMainWebUser() => WebUser.fromUser(_user);

  // Get all chats that involve _user, update local chat information
  // (lastUpdate & unread).
  Future<List<Chat>> getChats() async {
    await _syncWebUsers();
    return await _dataService.findAllChats(_user.id);
  }

  // Called whenever a new message is received in the UI-page 'chats'
  Future<void> receivedMessage(WebMessage message) async {
    final chat = await getChatWith(message.from);
    await addMessage(message, chat, ReceiptStatus.delivered);
  }

  // Update relevant local users with information from the webserver.
  _syncWebUsers() async {
    // Creates a list of all relevant users webId
    List<String> usersWebIdList = List<String>.empty(growable: true);
    final connectedUsers = await _dataService.findAllConnectedUsers(_user.id);
    for (User user in connectedUsers) { usersWebIdList.add(user.webUserId); }

    // Get a list of updated webUsers from webServer
    final updatedWebUsers = await _webUserService.fetch(usersWebIdList);

    // Update each local user with the updated webUser data
    for(WebUser webUser in updatedWebUsers) {
      final user = await _dataService.findWebUser(webUser.webUserId!);
      user!.update(webUser);
      await _dataService.saveUser(user);
    }
  }
}