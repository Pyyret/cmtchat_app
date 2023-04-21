
import 'package:cmtchat_app/models/users.dart';
import 'package:cmtchat_app/services/data/isar/isar_dataservice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {

  IsarService i = IsarService();

  setUp(() => {
    i = IsarService()
  });

  tearDown(() => {
    i
  });


  var ts = User();
  test('userdb', () => {



  });



  /*

  test('Save a new chat', () async {
    var ans = await i.saveChat(tstChat1);

    expect(ans, tstChat1.id);
  });


   */
}