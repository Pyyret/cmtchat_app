import 'dart:async';

import 'package:cmtchat_app/collections/cubits.dart';
import 'package:cmtchat_app/collections/models.dart';
import 'package:cmtchat_app/services/local/local_db_api.dart';
import 'package:cmtchat_app/services/web/message/web_message_service_api.dart';
import 'package:cmtchat_app/services/web/receipt/receipt_service_api.dart';


/// App repository ///
class Repository{

  /// Data Providers
  final LocalDbApi _localDb;
  final WebMessageServiceApi _webMessageService;
  final ReceiptServiceApi _receiptService;

  final RootCubit _rootCubit;

  /// Private variable
  final List<Receipt> _savedReceipts = List<Receipt>.empty(growable: true);

  /// Constructor
  Repository({
    required this.activeUser,
    required LocalDbApi dataService,
    required WebMessageServiceApi webMessageService,
    required ReceiptServiceApi receiptService,
    required RootCubit rootCubit })
      : _localDb = dataService,
        _webMessageService = webMessageService,
        _receiptService = receiptService,
        _rootCubit = rootCubit
  {
    // Initializing
    _subscribeToWebMessages();
    _subscribeToReceipts();
  }

  /// Active User getter
  final User  activeUser;

  /// Streams ///
  // For providing updates in the local database to HomeCubit & ChatCubit
  Stream<List<Chat>> allChatsUpdatedStream() async* {
    yield* await _localDb.allChatsStream(ownerId: activeUser.id);
  }
  Stream<List<Message>> chatMessageStream({required int chatId}) async* {
    yield* await _localDb.chatMessageStream(chatId);
  }

  /// Methods ///
  Future<void> updateReadMessages({required List<Message> msgList}) async {
    for(Message msg in msgList) {
      final receipt = Receipt.read(message: msg);
      msg.updateReceipt(receipt: receipt);
      _receiptService.send(receipt);
    }
    await _localDb.updateMessages(messages: msgList);
  }

  Future<void> sendMessage({
    required Chat chat,
    required WebMessage message})
  async {
    final sentMsg = Message.fromWebMessage(
        message: await _webMessageService.send(message: message),
        receiptStatus: ReceiptStatus.sent,
    );
    await _localDb.saveMessage(chat: chat, message: sentMsg);
    if(_savedReceipts.any((r) => r.messageId == sentMsg.webId)) {
      _updateMessageReceipt(
          receipt: _savedReceipts
              .lastWhere((r) => r.messageId == sentMsg.webId),
          message: sentMsg
      );
      _savedReceipts.removeWhere((r) => r.messageId == sentMsg.webId);
    }
  }

  Future<Chat> getChat(String webUserId) async {
    final chat = await _localDb.findChatWith(webUserId: webUserId)
        ?? Chat(
            ownerWebId: activeUser.webId!,
            receiver: await _rootCubit.fetchWebUser(webUserId: webUserId)
        );
    await _localDb.saveNewChat(chat: chat, owner: activeUser);
    return chat;
  }


  /// Private Methods ///
  _subscribeToWebMessages() {
    _webMessageService.messageStream(webUserId: activeUser.webUser.id!)
        .listen((msg) => _receivedMessage(msg));
  }

  _receivedMessage(WebMessage message) async {
    final localMessage = Message.fromWebMessage(
        message: message,
        receiptStatus: ReceiptStatus.delivered
    );
    _localDb.saveMessage(
        chat: await getChat(message.from),
        message: localMessage
    );
    _receiptService.send(Receipt.delivered(message: message)
    );
  }

  _subscribeToReceipts() {
    _receiptService.receiptStream(webUserId: activeUser.webUser.id!)
        .listen((receipt) async {
          final message = await _localDb
              .findMessageFrom(webId: receipt.messageId);
          if (message != null) {
            _updateMessageReceipt(receipt: receipt, message: message);
          }
          else { _savedReceipts.add(receipt); }
        });
  }

  Future<void> _updateMessageReceipt({
    required Receipt receipt,
    required Message message
  }) async{
    message.receiptStatus = receipt.status;
    message.receiptTimestamp = receipt.timestamp;
    await _localDb.updateMessages(messages: [message]);
  }
}