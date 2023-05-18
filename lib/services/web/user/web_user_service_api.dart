import 'package:cmtchat_app/models/web/web_user.dart';


abstract class WebUserServiceApi {
  Future<WebUser> connectNew(String username);
  Future<WebUser?> update({required WebUser webUser});
  Future<List<WebUser>> online();
  Future<List<WebUser>> fetch(List<String> ids);
  Stream<List<WebUser>> activeUsersStream();
  Future<void> cancelChangeFeed();
  dispose();
}