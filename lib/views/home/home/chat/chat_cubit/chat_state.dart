part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final bool working;
  final List<Message> messages;
  final String chatName;

  const ChatState({
    this.working = false,
    this.messages = const <Message>[],
    this.chatName = '',
  });

  @override
  List<Object?> get props => [working, messages, chatName];

  ChatState copyWith({
    bool? initialized,
    bool? working,
    List<Message>? messages,
    String? chatName,
  }) {
    return ChatState(
      working: working ?? this.working,
      messages: messages ?? this.messages,
      chatName: chatName ?? this.chatName,
    );
  }
}