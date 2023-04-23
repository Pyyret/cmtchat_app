import 'package:cmtchat_app/models/users.dart';
import 'package:cmtchat_app/services/data/isar/isar_dataservice.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_test.dart';


void main() {

  group('Path_provider dependant tests', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await Isar.initializeIsarCore(download: true);
    });

    // Just to test since this has been a problem during development
    test('Testing that "getApplicationDocumentsDirectory()" is working', () async {
        var dir = await getApplicationDocumentsDirectory();
        expect(dir, isNotNull);
    });

    test('Add and retrieve a user to the db, then remove', () async {
      IsarService i = IsarService();
      User user1 = User(newUsername: '123');

      await i.saveUser(user1);
      User? dbUser = await i.findUser(user1.id);

      expect(dbUser?.id, user1.id);
      expect(dbUser?.username, user1.username);

      await i.removeUser(user1.id);

      expect(await i.findUser(user1.id), isNull);
    });

  });

}
