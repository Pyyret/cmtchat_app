import 'package:cmtchat_app/collections/chat_message_collection.dart';
import 'package:cmtchat_app/collections/user_webuser_collection.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final List<Chat> chatList;
  final List<WebUser> activeUserList;
  const HomeState(this.chatList, this.activeUserList);
}

class HomeInitial extends HomeState {
  HomeInitial() : super([], []);
  @override
  List<Object> get props => [chatList, activeUserList];
}

class HomeLoading extends HomeState {
  HomeLoading() : super([], []);
  @override
  List<Object> get props => [chatList, activeUserList];
}

class HomeSynced extends HomeState {
  const HomeSynced(super.chatList, super.activeUserList);
  @override
  List<Object> get props => [chatList, activeUserList];
}