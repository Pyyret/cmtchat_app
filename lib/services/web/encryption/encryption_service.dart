import 'package:encrypt/encrypt.dart';

import 'encryption_service_api.dart';

class EncryptionService implements EncryptionServiceApi {
  final Encrypter _encrypter;
  final IV _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  String encrypt(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }
}