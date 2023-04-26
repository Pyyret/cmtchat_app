import 'package:cmtchat_app/models/web/web_user.dart';

abstract class IWebUserService {
  Future<WebUser> connect(WebUser user);
  Future<WebUser> disconnect(WebUser user);
  Future<List<WebUser>> online();
}