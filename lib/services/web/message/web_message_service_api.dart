
import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/models/web/web_message.dart';

abstract class WebMessageServiceApi {
  Future<WebMessage> send({required WebMessage message});
  Stream<WebMessage> messageStream({ required String webUserId});
  Future<void> dispose();
  Future<void> cancelChangeFeed();
}