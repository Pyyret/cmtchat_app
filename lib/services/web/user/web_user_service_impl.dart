import 'package:cmtchat_app/models/web/web_user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'web_user_service_contract.dart';

class WebUserService implements IWebUserService {
  final Connection _connection;
  final RethinkDb r;

  WebUserService(this.r, this._connection);

  @override
  Future<WebUser> connect(WebUser user) async {
    user.active = true;
    user.lastSeen = DateTime.now();

    final response = await r
        .table('users')
        .insert(user.toJson() , {
          'conflict': 'update',
          'return_changes': true
        })
        .run(_connection);

    if(response['changes'].length == 0) { return user; }
    else {
      return WebUser.fromJson(response['changes'].first['new_val']);
    }
  }

  @override
  Future<void> disconnect(WebUser user) async {
    await r.table('users').update({
      'id' : user.webUserId,
      'active': false,
      'last_seen': DateTime.now()
        })
        .run(_connection);
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
  Future<List<WebUser>> fetch(List<String?> ids) async {
    Cursor users = await r.table('users')
        .getAll(r.args(ids))
        .filter({
      'active' : true
        })
        .run(_connection);

    List userList = await users.toList();
    return userList.map((e) => WebUser.fromJson(e)).toList();
  }
}
