import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Interface ///
abstract class LocalCacheApi {
  Future<void> save(String key, Map<String, dynamic> json);
  Map<String, dynamic> fetch(String key);
  Future<void> clear();
}


class LocalCacheService implements LocalCacheApi {
  final SharedPreferences _sharedPreferences;

  LocalCacheService(this._sharedPreferences);

  @override
  Map<String, dynamic> fetch(String key) {
    return jsonDecode(_sharedPreferences.getString(key) ?? '{}');
  }

  @override
  Future<void> save(String key, Map<String, dynamic> json) async {
    await _sharedPreferences.setString(key, jsonEncode(json));
  }

  @override
  Future<void> clear() async => await _sharedPreferences.clear();

}