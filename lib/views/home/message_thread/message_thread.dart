/*

import 'dart:async';

import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/home_collection.dart';
import 'package:cmtchat_app/collections/message_thread_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';

import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/views/home/shared_blocs/receipt_bloc/receipt_bloc.dart';
import 'package:cmtchat_app/views/home/shared_blocs/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/views/shared_widgets/header_status_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

class MessageThread extends StatefulWidget {
  final Chat _chat;

  const MessageThread(this._chat, {super.key});

  @override
  State<MessageThread> createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  late final Chat _chat;

  @override
  void initState() {
    super.initState();
    _chat = widget._chat;
    //_updateOnMessageReceived();
    _updateOnReceiptReceived();
    //final webUser = WebUser.fromUser(_user);
    context.read<ReceiptBloc>().add(ReceiptEvent.onSubscribed(webUser));
  }

  @override
  Widget build(BuildContext context) {
    Stream<Chat> chatStream = context.read<HomeCubit>()
        .getChatSubscription(_chat.id);



    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.arrow_back_ios_rounded),
              color: isLightTheme(context) ? Colors.black : Colors.white,
            ),
            Expanded(
              child: HeaderStatus(
                _receiver.username ?? '',
                _receiver.photoUrl ?? '',
                _receiver.active ?? true,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Flexible(
              flex: 6,
              child: BlocBuilder<MessageThreadCubit, List<Message>>(
                builder: (_, messages) {
                  this.messages = messages;
                  if (this.messages.isEmpty) {
                    return Container(color: Colors.transparent);
                  }
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToEnd());
                  return _buildListOfMessages();
                },
              ),
            ),
            Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: isLightTheme(context) ? Colors.white : kAppBarDark,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, -3),
                          blurRadius: 6.0,
                          color: Colors.black12,
                        )
                      ]
                  ),
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildMessageInput(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Container(
                            height: 45.0,
                            width: 45.0,
                            child: RawMaterialButton(
                                fillColor: kPrimary,
                                shape: const CircleBorder(),
                                elevation: 5.0,
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: () => _sendMessage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  _buildMessageInput(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(90.0)),
      borderSide: isLightTheme(context)
          ? BorderSide.none
          : BorderSide(color: Colors.grey.withOpacity(0.3)),
    );

    return Focus(
      onFocusChange: (focus) {},
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: Theme
            .of(context)
            .textTheme
            .bodySmall,
        cursorColor: kPrimary,
        onChanged: (val) {},
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          enabledBorder: border,
          filled: true,
          fillColor:
          isLightTheme(context) ? kPrimary.withOpacity(0.1) : kBubbleDark,
          focusedBorder: border,
        ),
      ),
    );
  }

  _buildListOfMessages(List<Message> messages) =>
      ListView.builder(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 20.0),
        itemBuilder: (_, indx) {
          if (messages[indx].from.value!.id == _receiver.id) {
            _sendReceipt(messages[indx]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ReceiverMessage(messages[indx]),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SenderMessage(messages[indx]),
            );
          }
        },
        itemCount: messages.length,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
      );

/*
  void _updateOnMessageReceived() {

      if (state is WebMessageReceivedSuccess) {
        //await messageThreadCubit.viewModel.receivedMessage(state.message);
        final receipt = Receipt(
            recipient: state.message.from,
            messageId: state.message.webId,
            status: ReceiptStatus.read,
            timestamp: DateTime.now()
        );
        context.read<ReceiptBloc>().add(ReceiptEvent.onReceiptSent(receipt));
      }


      if (state is WebMessageSentSuccess) {
        await messageThreadCubit.viewModel.sentMessage(state.message);
      }
      await messageThreadCubit.messages(_chat);
    });
  }

 */

  void _updateOnReceiptReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    context.read<ReceiptBloc>().stream.listen((state) async {
      if (state is ReceiptReceivedSuccess) {
        await messageThreadCubit.viewModel.updateMessageReceipt(state.receipt);
        await messageThreadCubit.messages(_chat);
      }
    });
  }

  _sendMessage() {
    if(_textEditingController.text.trim().isEmpty) { return; }
    final webMessage = WebMessage(
        to: _receiver.webUserId,
        from: _user.webUserId,
        timestamp: DateTime.now(),
        contents: _textEditingController.text
    );

    final sendMessageEvent = WebMessageEvent.onMessageSent(webMessage);
    widget._webMessageBloc.add(sendMessageEvent);

    _textEditingController.clear();
  }

  _scrollToEnd() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut
    );
  }

  _sendReceipt(Message message) async {
    if(message.status == ReceiptStatus.read) { return; }

    final receipt = Receipt(
        recipient: message.from.value!.webUserId,
        messageId: message.webId,
        status: ReceiptStatus.read,
        timestamp: DateTime.now()
    );
    context.read<ReceiptBloc>().add(ReceiptEvent.onReceiptSent(receipt));
    await context.read<MessageThreadCubit>()
        .viewModel
        .updateMessageReceipt(receipt);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _subscription.cancel();
    super.dispose();
  }
}


 */