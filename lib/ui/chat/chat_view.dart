import 'package:cmtchat_app/collections/cubits.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/ui/chat/receiver_message.dart';
import 'package:cmtchat_app/ui/chat/sender_message.dart';
import 'package:cmtchat_app/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ChatView extends StatelessWidget {
  ChatView({super.key,});

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _chatsAppBar(context),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(children: [
              Flexible(
                flex: 6,
                child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (_, state) {
                      if (state.messages.isEmpty) {
                        return Container(color: Colors.transparent);
                      } else {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _scrollToEnd());
                        final messages = state.messages;
                        final ownerWebId = context.read<ChatCubit>().ownerWebId;
                        return _buildListOfMessages(messages, ownerWebId);
                      }
                    }),
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

  _buildListOfMessages(List<Message> messages, String ownerWebId) {
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

  _chatsAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              //context.read<ChatCubit>().close();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: isLightTheme(context) ? Colors.black : Colors.white,
          ),
          Expanded(child: _headerStatus()),
        ],
      ),
    );
  }

  _headerStatus() {
    return Builder(builder: (context) {
      final receiver  = context.select((ChatCubit c) => c.receiver);
      final status = context.select(
              (HomeCubit c) => c.state.onlineUsers.any(
                      (webUser) => webUser.id == receiver.id));
      return Container(
          width: double.maxFinite,
          child: Row(children: [
            _profilePlaceholder(),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  receiver.username,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(status ? 'online' : 'offline',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ]),
          ])
      );
    });


  }

  _profilePlaceholder() {
    const double size = 50.0;
    return Container(
      height: size,
      width: size,
      child: Builder(builder: (context) {
        return Material(
          color: isLightTheme(context)
              ? const Color(0xFFF2F2F2)
              : const Color(0xFF211E1E),
          borderRadius: BorderRadius.circular(size),
          child: InkWell(
            borderRadius: BorderRadius.circular(size),
            onTap: () {},
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person_outline_rounded,
                size: size,
                color: isLightTheme(context) ? kIconLight : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }
}
