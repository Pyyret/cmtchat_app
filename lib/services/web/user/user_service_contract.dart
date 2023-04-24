import '../../models/user.dart';

abstract class IUserService {
  Future<User> connect(User user);
  Future<User> disconnect(User user);
  Future<List<User>> online();
}