/// Enum ///
enum HomeStatus { init, loading, ready, failure }

/// State ///
class HomeState extends Equatable {
  final HomeStatus status;
  final List<Chat> chatsList;
  final List<WebUser> activeUserList;

  const HomeState({
    this.status = HomeStatus.init,
    this.chatsList = const <Chat>[],
    this.activeUserList = const <WebUser>[],
  });

  HomeState copyWith({
    HomeStatus Function()? status,
    List<Chat> Function()? chatsList,
    List<WebUser> Function()? activeUserList,
  }) {
    return HomeState(
      status: status != null ? status() : this.status,
      chatsList: chatsList != null ? chatsList() : this.chatsList,
      activeUserList: activeUserList != null ? activeUserList() : this.activeUserList,
    );
  }

  @override
  List<Object> get props => [status, chatsList, activeUserList];
}

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