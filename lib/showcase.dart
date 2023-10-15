import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../../../models/local/message.dart';
import '../../../models/local/user.dart';
import '../../models/web/receipt.dart';
/*
Future<void> main() async {

  RethinkDb r = RethinkDb();
  final Connection connection = await r.connect(host:'172.29.32.1', port:28015);
  await r.dbCreate('test').run(connection);
  await r.tableCreate('users').run(connection);


  var user =
  {
    'username': 'Jane Doe',
    'active': true,
    'last_seen': DateTime.now(),
  };

  final response = await r
      .table('users')
      .insert(user,
      {
        'conflict': 'update',
        'return_changes': true
      })
      .run(connection);


  // Isar show
  Message message = Message(
      webId: 'fd',
      toWebId: 'toWebId',
      fromWebId: 'fromWebId',
      contents: 'contents',
      receiptStatus: ReceiptStatus.delivered
  );


  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
      [UserSchema],
      directory: dir.path
  );

  final newUser = User()..username = 'Jane Doe';
  newUser.messages.add(message);
  await isar.writeTxn(() async => await isar.users.put(newUser));

}


@collection
class User {
  Id id = Isar.autoIncrement;
  String? username;

  final messages = IsarLinks<Message>();
}


 */



