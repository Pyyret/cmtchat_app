
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';

abstract class IWebMessageService {
  Future<bool> send({required WebMessage message});
  Stream<WebMessage> messageStream({ required WebUser activeUser });
  dispose();
}