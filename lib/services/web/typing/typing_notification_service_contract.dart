import 'package:cmtchat_app/models/web/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';

abstract class ITypingNotification {
  Future<bool> send({ required TypingEvent event, required WebUser to });
  Stream<TypingEvent> subscribe(WebUser user, List<String> userWebIds);
  void dispose();
}