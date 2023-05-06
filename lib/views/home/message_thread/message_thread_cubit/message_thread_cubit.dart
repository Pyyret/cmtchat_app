import 'package:bloc/bloc.dart';
import 'package:cmtchat_app/models/local/chat.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/viewmodels/chat_view_model.dart';

class MessageThreadCubit extends Cubit<List<Message>> {
  final ChatViewModel viewModel;
  MessageThreadCubit(this.viewModel) : super([]);

  Future<void> messages(Chat chat) async {
    final messages = await viewModel.getMessages(chat);
    emit(messages);
  }
}