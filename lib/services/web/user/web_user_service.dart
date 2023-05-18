import 'dart:async';

import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'web_user_service_api.dart';

class WebUserService implements WebUserServiceApi {
  final Connection _connection;
  final RethinkDb r;

  final StreamController<List<WebUser>>_controller =
              StreamController<List<WebUser>>.broadcast();
  StreamSubscription? _changeFeed;

  WebUserService(this.r, this._connection);

  @override
  Future<WebUser> connectNew(String username) async {
    final response = await r
        .table('users')
        .insert(
        {
          'username': username,
          'photo_url': '',
          'active': true,
          'last_seen': DateTime.now()
        },
        {
          'conflict': 'update',
          'return_changes': true
        })
        .run(_connection);
    return WebUser.fromJson(response['changes'].first['new_val']);
  }

  @override
  Future<WebUser?> update({required WebUser webUser}) async {
    webUser.lastSeen = DateTime.now();
    final response = await r
        .table('users')
        .insert(webUser.toJson(),
        {
          'conflict': 'update',
          'return_changes': true
        })
        .run(_connection);
    if(response['changes'].length == 0) { return null; }
    else { return WebUser.fromJson(response['changes'].first['new_val']); }
  }

  @override
  Future<List<WebUser>> fetch(List<String> ids) async {
    Cursor users = await r.table('users')
        .getAll(r.args(ids))
        .filter({'active' : true})
        .run(_connection);
    List userList = await users.toList();
    return userList.map((e) => WebUser.fromJson(e)).toList();
  }

  @override
  Future<List<WebUser>> online() async {
    Cursor users = await r
        .table('users')
        .filter({'active': true})
        .run(_connection);
    final userList = await users.toList();
    return userList.map((item) => WebUser.fromJson(item)).toList();
  }

  @override
  Stream<List<WebUser>> activeUsersStream() {
    _startReceivingWebUsers();
    return _controller.stream;
  }


  _startReceivingWebUsers() {
    _changeFeed = r
        .table('users')
        .filter({'active' : true})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          List<WebUser> webUserList = List<WebUser>.empty(growable: true);
          event.forEach((userData) {
            if(userData['new_val'] != null) {
              final newUser = WebUser.fromJson(userData['new_val']);
              webUserList.removeWhere(
                      (user) => user.id == newUser.id);
              webUserList.add(newUser);
            }
            else {
              final unactiveUser = WebUser.fromJson(userData['old_val']);
              webUserList.removeWhere(
                      (user) => user.id == unactiveUser.id);
            }
            _controller.sink.add(webUserList.toList());
          });
        });
    }

  @override
  Future<void> cancelChangeFeed() async {
    if(_changeFeed != null){
      await _changeFeed?.cancel();
    }
  }

  @override
  dispose() async {
    _changeFeed?.cancel();
    _controller.close();
  }
}
