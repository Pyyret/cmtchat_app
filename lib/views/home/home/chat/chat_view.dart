import 'package:cmtchat_app/collections/message_thread_collection.dart';
import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/local/user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:cmtchat_app/views/home/shared_blocs/web_message/web_message_bloc.dart';
import 'package:cmtchat_app/views/shared_widgets/header_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubit_bloc/chat_cubit.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final User _user; // = context.read<ChatCubit>();
  late final User _receiver; // = context.read<ChatCubit>();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              child: Builder(builder: (context) {
                final chatName =
                context.select((ChatCubit cubit) => cubit.state.chatName);
                return HeaderStatus(chatName, '', true);
              }),
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
              child: BlocSelector<ChatCubit, ChatState, List<Message>>(
                selector: (state) => state.messages,
                builder: (_, messages) {
                  if (messages.isEmpty) {
                    return Container(color: Colors.transparent);
                  } else {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToEnd());

                    return _buildListOfMessages(messages);
                  }
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
                      ]),
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
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
                )),
          ],
        ),
      ),
    );
  }

  _buildListOfMessages(List<Message> messages) => ListView.builder(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 20.0),
        itemBuilder: (_, indx) {
          if (messages[indx].to.value!.id == _user.id) {
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
        style: Theme.of(context).textTheme.bodySmall,
        cursorColor: kPrimary,
        onChanged: (val) {},
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          enabledBorder: border,
          filled: true,
          fillColor:
              isLightTheme(context) ? kPrimary.withOpacity(0.1) : kBubbleDark,
          focusedBorder: border,
        ),
      ),
    );
  }

  _sendMessage() {
    if (_textEditingController.text.trim().isEmpty) { return; }
    final webMessage = WebMessage(
        to: _receiver.webId!,
        from: _user.webId!,
        timestamp: DateTime.now(),
        contents: _textEditingController.text);

    final sendMessageEvent = WebMessageEvent.onMessageSent(webMessage);
    context.read<WebMessageBloc>().add(sendMessageEvent);

    _textEditingController.clear();
  }

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }
}
