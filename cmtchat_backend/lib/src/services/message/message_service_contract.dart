import 'package:flutter/cupertino.dart';

import '../../models/message.dart';
import '../../models/user.dart';

abstract class IMessageService {
  Future<bool> send({required Message message});
  Stream<Message> messageStream({ required User activeUser });
  dispose();
}