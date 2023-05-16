part of 'web_message_bloc.dart';

abstract class WebMessageState extends Equatable {
  const WebMessageState();
  factory WebMessageState.initial() => WebMessageInitial();
  factory WebMessageState.sent(WebMessage message) => WebMessageSentSuccess(message);
  factory WebMessageState.received(WebMessage message) => WebMessageReceivedSuccess(message);

  @override
  List<Object> get props => [];
}

class WebMessageInitial extends WebMessageState {}

class WebMessageSentSuccess extends WebMessageState {
  final WebMessage message;
  const WebMessageSentSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class WebMessageReceivedSuccess extends WebMessageState {
  final WebMessage message;
  const WebMessageReceivedSuccess(this.message);

  @override
  List<Object> get props => [message];
}