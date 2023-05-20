import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:cmtchat_app/collections/models.dart';
import 'package:cmtchat_app/repository.dart';

/// Chat Cubit
class ChatCubit extends Cubit<List<Message>> {
  /// Data Provider
  final Repository _repo;

  /// Private variables
  final Chat _chat;
  late final StreamSubscription<List<Message>> _messageSub;

  /// Constructor
  ChatCubit({required Repository repository, required Chat chat})
      : _repo = repository,
        _chat = chat,
        super(const [])
  {
    // Initializing
    _subscribeToChatMessages();
    print('ChatCubit created');
  }

  /// Getters
  String get ownerWebId => _chat.ownerWebId;
  WebUser get receiver => _chat.receiver;

  /// Public Methods
  void sendMessage({required String contents}) {
    final message = WebMessage(
        to: receiver.id,
        from: ownerWebId,
        timestamp: DateTime.now(),
        contents: contents,
    );
    _repo.sendMessage(chat: _chat, message: message);
  }

  @override
  close() async {
    await _messageSub.cancel();
    print('ChatCubit closed');
    super.close();
  }

  /// Private methods
  _subscribeToChatMessages() async {
    _messageSub = await _repo
        .chatMessageStream(_chat.id)
        .then((stream) => stream
        .listen((messageList) async {
          final unreadMsgList = messageList
              .where((message) => message
              .receiptStatus == ReceiptStatus.delivered
              && message.toWebId == _chat.ownerWebId)
              .toList();
          if(unreadMsgList.isNotEmpty) {
            await _repo.updateReadMessages(unreadMsgList);
          }
          else { emit(messageList); }
        }));
  }
}