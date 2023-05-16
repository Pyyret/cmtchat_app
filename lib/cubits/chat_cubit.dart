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
  /// Constructor
  ChatCubit({required Repository repository, required Chat chat})
      : _repo = repository,
        _chat = chat,
        super(const ChatState(messages: []))
  {
    // Initializing
    _subscribeToChatMessages();
  }

  /// Private variables
  final Repository _repo;
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