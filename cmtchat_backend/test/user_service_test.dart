import 'package:cmtchat_backend/src/models/user.dart';
import 'package:cmtchat_backend/src/services/user/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late UserService sut;

  User testPilot = User(
    username: 'test',
    photoUrl: 'url',
    active: true,
    lastSeen: DateTime.now(),
  );

  setUp(() async {
    testPilot = User(
        username: 'test',
        photoUrl: 'url',
        active: false,
        lastSeen: DateTime.now()
    );
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = UserService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
    connection.close();
  });

  test('Connect new user to database and receive unique _id', () async {
    testPilot = await sut.connect(testPilot);
    expect(testPilot.id == null, false);
    expect(testPilot.active, true);
  });

  test('Testing update. Connect, disconnect, connect again', () async {
    testPilot = await sut.connect(testPilot);
    expect(testPilot.id == null, false);
    expect(testPilot.active, true);

    testPilot = await sut.disconnect(testPilot);
    expect(testPilot.active, false);

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

    testPilot = await sut.disconnect(testPilot);
    users = await sut.online();
    expect(users.length, 0);
  });
}