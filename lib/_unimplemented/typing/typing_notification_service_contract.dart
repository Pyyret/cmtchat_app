import 'package:cmtchat_app/_deprecated/models/typing_event.dart';
import 'package:cmtchat_app/models/web/web_user.dart';

abstract class ITypingNotification {
  Future<bool> send({ required List<TypingEvent> events});
  Stream<TypingEvent> subscribe(WebUser user, List<String> userWebIds);
  void dispose();
}