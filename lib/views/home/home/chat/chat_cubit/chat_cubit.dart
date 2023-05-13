import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/isar_db_collection.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/views/home/shared_blocs/receipt_bloc/receipt_bloc.dart';
import 'package:equatable/equatable.dart';
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final LocalDbApi _dataService;
  final ReceiptBloc _receiptBloc;
  final Chat _chat;
  final User _user;
  late final User _receiver;
  
  ChatCubit(this._dataService, this._receiptBloc, this._user, this._chat) : super(const ChatState()) {
    _receiver = _chat.owners.where((user) => user.id != _user.id).single;
    //_listenForChange();
  }
/*
  get user => _user;
  get receiver => _receiver;

  _listenForChange() async {
    Stream<Chat?> chatUpdateStream = await _dataService.chatUpdateStream(_chat.id);
    chatUpdateStream.listen((Chat? chat) {
      if(chat == null) { return; }

      if(chat.chatName != state.chatName) {
        emit(state.copyWith(chatName: chat.chatName));
      }

      if(state.working) { return; }
      else if(chat.unread > 0) {
        emit(state.copyWith(working: true));
        _readAll(chat.messages.toList());
      }
      else { emit(state.copyWith(messages: chat.messages.toList())); }
    });
  }

 */

  Future<void> _readAll(List<Message> messageList) async {
    for(Message msg in messageList) {
      if(msg.to.value!.id == _user.id) {
        final Receipt receipt = Receipt(
            recipient: msg.from.value!.webUserId!,
            messageId: msg.webId!,
            status: ReceiptStatus.read,
            timestamp: DateTime.now()
        );
        _receiptBloc.add(ReceiptEvent.onReceiptSent(receipt));
        await _dataService.updateMessageReceipt(msg.webId!, receipt);
      }
    }

    final messages = await _dataService.findAllMessages(_chat.id);
    emit(state.copyWith(working: false, messages: messages));
  }

}

