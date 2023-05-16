part of 'web_message_bloc.dart';

abstract class WebMessageEvent extends Equatable {
  const WebMessageEvent();
  factory WebMessageEvent.onSubscribed(WebUser user) => Subscribed(user);
  factory WebMessageEvent.onMessageSent(WebMessage message) => WebMessageSent(message);

  @override
  List<Object> get props => [];
}

class Subscribed extends WebMessageEvent {
  final WebUser user;
  const Subscribed(this.user);

  @override
  List<Object> get props => [user];
}

class WebMessageSent extends WebMessageEvent {
  final WebMessage message;
  const WebMessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class _WebMessageReceived extends WebMessageEvent {
  final WebMessage message;
  const _WebMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}