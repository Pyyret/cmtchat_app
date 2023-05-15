
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:equatable/equatable.dart';

/// Chat State ///
class ChatState extends Equatable {
  /// State variables
  final List<Message> messages;

  /// Constructor
  const ChatState({required this.messages});


  @override
  List<Object> get props => [messages];
}

/// Chat Cubit
class ChatCubit extends Cubit<ChatState> {
  final AppRepository _repo;
  final Chat _chat;

  StreamSubscription<List<Message>>? _messageSub;

  ChatCubit({required AppRepository repository, required Chat chat})
      :
        _repo = repository,
        _chat = chat,
        super(const ChatState(messages: []))
  {
    // Initializing
    _subscribeToChatMessages();
  }

  User get receiver => _chat.receiver.value!;
  int get userId => _repo.user.id;

  void sendMessage({required String contents}) {
    _repo.sendMessage(chat: _chat,contents: contents);
  }

  _subscribeToChatMessages() async {
    await _messageSub?.cancel();
    final messageStream = await _repo.chatMessageStream(chatId: _chat.id);
    _messageSub = messageStream
        .listen((messageList) => emit(ChatState(messages: messageList)));
  }

}

  /*

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



   */