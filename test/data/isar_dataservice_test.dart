import 'package:cmtchat_app/models/chat.dart';
import 'package:cmtchat_app/services/data/isar/isar_dataservice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  IsarService i = IsarService();

  setUp(() => {
    i = IsarService()
  });

  tearDown(() => {});


  var tstChat1 = Chat();

  test('Save a new chat', () async {
    var ans = await i.saveChat(tstChat1);

    expect(ans, tstChat1.id);
  });

}