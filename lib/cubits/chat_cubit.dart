import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:cmtchat_app/collections/models.dart';
import 'package:cmtchat_app/repository.dart';

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
  /// Data Provider
  final Repository _repo;

  /// Private variables
  final Chat _chat;
  StreamSubscription<List<Message>>? _messageSub;

  /// Constructor
  ChatCubit({required Repository repository, required Chat chat})
      : _repo = repository,
        _chat = chat,
        super(const ChatState(messages: []))
  {
    // Initializing
    _subscribeToChatMessages();
    print('ChatCubit created');
  }

  /// Getters
  String get ownerWebId => _chat.ownerWebId;
  WebUser get receiver => _chat.receiver;


  /// Methods
  void sendMessage({required String contents}) {
    final message = WebMessage(
        to: receiver.id,
        from: ownerWebId,
        timestamp: DateTime.now(),
        contents: contents );
    _repo.sendMessage(chat: _chat, message: message);
  }



  @override
  close() async {
    await _messageSub?.cancel();
    print('ChatCubit closed');
    super.close();
  }

  /// Private methods
  _subscribeToChatMessages() async {
    _messageSub = _repo
        .chatMessageStream(chatId: _chat.id)
        .listen((messageList) async {
          final unreadMessagesList = messageList.where(
                  (message) => message.receiptStatus == ReceiptStatus.delivered
                      && message.toWebId == _chat.ownerWebId)
              .toList();
          if(unreadMessagesList.isNotEmpty) {
            await _repo.updateReadMessages(msgList: unreadMessagesList);
          }
          else { emit(ChatState(messages: messageList)); }
        });
  }
}