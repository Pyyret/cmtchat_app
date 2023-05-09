import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:cmtchat_app/services/web/user/web_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';


void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late WebUserService sut;

  WebUser testPilot = WebUser(
    username: 'test',
    photoUrl: 'url',
    active: true,
    lastSeen: DateTime.now(),
  );

  setUp(() async {
    testPilot = WebUser(
        username: 'test',
        photoUrl: 'url',
        active: false,
        lastSeen: DateTime.now()
    );
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = WebUserService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
    connection.close();
  });

  test('Connect new user to database and receive unique _webId', () async {
    testPilot = await sut.connect(testPilot);
    expect(testPilot.webUserId == null, false);
    expect(testPilot.active, true);
  });

  test('Testing update. Connect, disconnect, connect again', () async {
    testPilot = await sut.connect(testPilot);
    expect(testPilot.webUserId == null, false);
    expect(testPilot.active, true);

    await sut.disconnect(testPilot);

    DateTime oldDateTime = testPilot.lastSeen;
    testPilot = await sut.connect(testPilot);
    expect(testPilot.active, true);
    expect(oldDateTime.compareTo(testPilot.lastSeen) < 0, false);
  });

  test('Get online users', () async {
    testPilot = await sut.connect(testPilot);
    var users = await sut.online();
    expect(users.length, 1);
    expect(users.first.username, 'test');

    await sut.disconnect(testPilot);
    users = await sut.online();
    expect(users.length, 0);
  });
}