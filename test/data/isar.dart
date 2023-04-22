import 'dart:io';

import 'package:cmtchat_app/models/users.dart';
import 'package:cmtchat_app/services/data/isar/isar_dataservice.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';


Future<void> main() async {


  test('description', ()  async {
  TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('aaaa', () async {
    WidgetsFlutterBinding.ensureInitialized();
      final Directory result = await getApplicationSupportDirectory();

  });


test('description', () async {
  WidgetsFlutterBinding.ensureInitialized();
  IsarService i = IsarService();

    var tor = User(newUsername: 'tor');

    final isar = await i.db;

    var x = isar.writeTxnSync<int>(() => isar.users.putSync(tor));
});






}
