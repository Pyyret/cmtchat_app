import 'package:cmtchat_app/collections/cubits.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/ui/chat/receiver_message.dart';
import 'package:cmtchat_app/ui/chat/sender_message.dart';
import 'package:cmtchat_app/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_app_bar.dart';


class ChatView extends StatelessWidget {
  ChatView({super.key,});

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const ChatAppBar(),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(children: [
              Flexible(
                flex: 6,
                child: _buildListOfMessages(),
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
                            onPressed: () {
                              if (_textEditingController.text.trim().isNotEmpty) {
                                context.read<ChatCubit>().sendMessage(
                                    contents: _textEditingController.text
                                );
                                _textEditingController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            ])));
  }

  _buildListOfMessages() {
    return BlocBuilder<ChatCubit, List<Message>>(
        builder: (context, messages) {
          if (messages.isEmpty) { return Container(color: Colors.transparent); }
          else {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
            final ownerWebId = context.read<ChatCubit>().ownerWebId;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 20.0),
              itemBuilder: (context, indx) {
                if (messages[indx].toWebId == ownerWebId) {
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
          }
        });
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

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }
}
