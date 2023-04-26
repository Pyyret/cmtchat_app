import 'package:cmtchat_app/viewmodels/base_view_model.dart';
import 'package:cmtchat_app/services/local/data/dataservice_contract.dart';

import '../models/local/message.dart';

class ChatsViewModel extends BaseViewModel {
  IDataService _dataService;

  ChatsViewModel(this._dataService) : super(_dataService);

  Future<void> receivedMessage(Message message) async {
    Message newMessage = Message(
        message: message,
        receipt: Receipt(
            status: ReceiptStatus.delivered,
            timestamp: DateTime.now())
    );
    await addMessage(newMessage);
  }

}