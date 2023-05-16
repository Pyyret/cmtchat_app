import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/repository/app_repository.dart';
import 'package:equatable/equatable.dart';

/// Chat State ///
class ChatState extends Equatable {
  /// Constructor
  const ChatState({required this.messages});

  /// State variables
  final List<Message> messages;

  @override
  List<Object> get props => [messages];
}

/// Chat Cubit
class ChatCubit extends Cubit<ChatState> {
  /// Constructor
  ChatCubit({required AppRepository repository, required Chat chat})
      : _repo = repository,
        _chat = chat,
        super(const ChatState(messages: []))
  {
    // Initializing
    _subscribeToChatMessages();
  }

  /// Private variables
  final AppRepository _repo;
  final Chat _chat;
  StreamSubscription<List<Message>>? _messageSub;


  /// Getters
  User get receiver => _chat.receiver.value!;
  int get userId => _repo.user.id;

  /// Methods
  void sendMessage({required String contents}) {
    final message = WebMessage(
        to: receiver.webId,
        from: _repo.userWebId,
        timestamp: DateTime.now(),
        contents: contents );
    _repo.sendMessage(chat: _chat, message: message);
  }

  /// Private methods
  _subscribeToChatMessages() async {
    await _messageSub?.cancel();
    final messageStream = _repo.chatMessageStream(chatId: _chat.id);
    _messageSub = messageStream.listen((messageList) async {
      final unreadMessagesList = messageList.where((message) {
        return message.status == ReceiptStatus.delivered
            && message.to.value!.id == userId; })
          .toList();
      if(unreadMessagesList.isNotEmpty) {
        await _repo.updateReadMessages(msgList: unreadMessagesList);
      }
      else { emit(ChatState(messages: messageList)); }
    });
  }

  @override
  close() async {
    await _messageSub?.cancel();
    super.close();
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