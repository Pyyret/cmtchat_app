import 'package:cmtchat_app/models/web/web_user.dart';


abstract class WebUserServiceApi {
  Future<WebUser> connect(WebUser user);
  Future<void> disconnect(WebUser user);
  Future<List<WebUser>> online();
  Future<List<WebUser>> fetch(List<String> ids);
  Stream<List<WebUser>> activeUsersStream();
  Future<void> cancelChangeFeed();
  dispose();
}