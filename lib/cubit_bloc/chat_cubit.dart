
import 'dart:async';

import 'package:bloc/bloc.dart';
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

  ChatCubit({
    required AppRepository repository, required Chat chat})
      :
        _repo = repository,
        _chat = chat,
        super(const ChatState(messages: []))
  {
    // Initializing
    _subscribeToChatMessages();
  }

  User get receiver => _chat.owners.singleWhere((user) => user.id != _repo.user.id);
  int get userId => _repo.user.id;

  _subscribeToChatMessages() async {
    await _messageSub?.cancel();
    final messageStream = await _repo.chatMessageStream(chatId: _chat.id);
    _messageSub = messageStream
        .listen((messageList) => emit(ChatState(messages: messageList)));
  }

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