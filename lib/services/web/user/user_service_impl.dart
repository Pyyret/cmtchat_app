import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../../models/user.dart';
import 'user_service_contract.dart';

class UserService implements IUserService {
  final Connection _connection;
  final RethinkDb r;

  UserService(this.r, this._connection);

  @override
  Future<User> connect(User user) async {
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
      return User.fromJson(response['changes'].first['new_val']);
    }
  }

  @override
  Future<User> disconnect(User user) async {
    final response = await r
        .table('users')
        .get(user.id)
        .update(
        {
          'active': false,
          'last_seen': DateTime.now()
        }, {'return_changes': true})
        .run(_connection);

    if(response['changes'].length > 0) {
      return User.fromJson(response['changes'].first['new_val']);
    } else {
      return user;
    }
  }

  @override
  Future<List<User>> online() async {
    Cursor users = await r
        .table('users')
        .filter({'active': true})
        .run(_connection);
    final userList = await users.toList();
    return userList.map((item) => User.fromJson(item)).toList();
  }
}
