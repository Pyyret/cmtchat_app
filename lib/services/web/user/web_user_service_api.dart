import 'package:cmtchat_app/models/web/web_user.dart';

abstract class WebUserServiceApi {
  Future<WebUser> connect(WebUser user);
  Future<void> disconnect(WebUser user);
  Future<void> cancelChangeFeed();
  Stream<List<WebUser>> activeUsersStream();
  dispose();
  Future<List<WebUser>> online();
  Future<List<WebUser>> fetch(List<String> ids);

}