import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState2 extends Equatable {
  final List<Chat> chatList;
  final List<WebUser> activeUserList;
  const HomeState2(this.chatList, this.activeUserList);
}

class HomeInit extends HomeState2 {
  HomeInit() : super([], []);
  @override
  List<Object> get props => [chatList, activeUserList];
}

class LoadingHome extends HomeState2 {
  LoadingHome() : super([], []);
  @override
  List<Object> get props => [chatList, activeUserList];
}

class SyncedHome extends HomeState2 {
  const SyncedHome(super.chatList, super.activeUserList);
  @override
  List<Object> get props => [chatList, activeUserList];
}