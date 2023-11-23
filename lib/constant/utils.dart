import 'package:multi_cipher/multi_cipher.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import 'package:wms/models/user_logs.dart';
import 'package:wms/modules/http.dart';

class Utils {
  static String baseUrl =
      Device.deviceType == DeviceType.web ? "localhost:3000" :
       "10.0.2.2:3000";
  static String register = "user/register";
  static String login = "user/login";
  static String getAdminKey = "user/getAdminPublicKey";
  static String logs = "logs/upload";
  static String allLogs = "logs/all";
  static String allLogsAdmin = "logs/allasAdmin";

  static List<UserLogs> getLogsFromJSON(Map<dynamic, dynamic> data) {
    // final data = jsonDecode(json);
    final List<UserLogs> logs =
        data['logs'].map((log) => UserLogs.fromJson(log)).toList<UserLogs>();
    print(logs.toString());
    return logs;
  }

  static final key = Key.fromUtf8('evrydayifalldeeperforcrptography');
  static final fernet = Fernet(key);
  static final encrypterFernet = Encrypter(fernet);
  static encryptFernet(text) {
    final encryptedText = encrypterFernet.encrypt(text);
    print(encryptedText.base64);
    return encryptedText.base64;
  }

  static decryptFernet(text) {
    final decryptedText = encrypterFernet.decrypt(Encrypted.fromBase64(text));
    print(decryptedText);
    return decryptedText;
  }

  static final salsa20Key = Key.fromUtf8('evrydayifalldeeperforcrptography');
  static final ivSalsa20 = IV.fromUtf8('kripasik');

  static final encrypterSalsa20 = Encrypter(Salsa20(salsa20Key));

  static encryptSalsa20(text) {
    return encrypterSalsa20.encrypt(text, iv: ivSalsa20).base64;
  }
  // static decryptSalsa20(text) {
  //   return encrypterSalsa20.decrypt(Encrypted.fromBase64(text), iv: ivSalsa20);
  // }

  static String decryptSalsa20(String text) {
    String paddedText = text;
    if (!text.endsWith('==')) {
      if (!text.endsWith('=')) {
        paddedText = '$paddedText=';
      }
      paddedText = '$paddedText=';
    }
    try {
      return encrypterSalsa20.decrypt(Encrypted.fromBase64(paddedText),
          iv: ivSalsa20);
    } catch (e) {
      if (e is FormatException) {
        String normalizedText = text.replaceAll(RegExp(r'\s'), '');
        text = normalizedText.replaceAll(RegExp(r'[^A-Za-z0-9+/=_]'), '');
        if (text.length % 4 != 0) {
          text += '=' * (4 - text.length % 4);
        }
        try {
          return encrypterSalsa20.decrypt(Encrypted.fromBase64(text),
              iv: ivSalsa20);
        } catch (e) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  static Future<UserLogs> logEncryption(UserLogs logs) async {
    final prefs = await SharedPreferences.getInstance();
    var vigenere = Vigenere('kripasik');
    String vigenereTitle = vigenere.encrypt(logs.title);
    String vigenereDescription = vigenere.encrypt(logs.description);
    var encryptedTitle = Utils.encryptSalsa20(vigenereTitle);
    // await RSA.encryptPKCS1v15(vigenereTitle, adminPublicKey);
    var encryptedDescription = Utils.encryptSalsa20(vigenereDescription);
    // await RSA.encryptPKCS1v15(vigenereDescription, adminPublicKey);

    final plainText = logs.image;
    final encryptedImage = Utils.encryptFernet(plainText);
    return UserLogs(
        title: encryptedTitle,
        description: encryptedDescription,
        image: encryptedImage,
        userEmail: logs.userEmail);
  }

  static Future<UserLogs> logDecryption(UserLogs logs) async {
    var vigenere = Vigenere('kripasik');
    var decryptSalsaTitle = Utils.decryptSalsa20(logs.title);
    // await RSA.encryptPKCS1v15(vigenereTitle, adminPublicKey);
    var decryptSalsaDescription = Utils.decryptSalsa20(logs.description);

    String decryptedTitle = vigenere.encrypt(decryptSalsaTitle);
    String decryptedDescription = vigenere.encrypt(decryptSalsaDescription);
    final encryptedImage = logs.image;
    final decryptedImage = decryptFernet(encryptedImage);
    return UserLogs(
        title: decryptedTitle,
        description: decryptedDescription,
        image: decryptedImage,
        userEmail: logs.userEmail);
  }

  static Future<UserLogs> superDecryptasAdmin(UserLogs logs) async {
    // final prefs = await SharedPreferences.getInstance();
    // // var adminPublicKey = '';
    // // var res = await getAdminPublicKey();
    // // if (res['success']) {
    // //   adminPublicKey = res['user'][0]['public_key'];
    // // } else {
    // //   print('gagal lmao');
    // // }
    // // var email = 'admin@gmail.com';
    // // var adminPrivateKey = prefs.getString('${email}privatekey')!;
    // // print('Private key: $adminPrivateKey');

    var rsaDecryptedTitle = decryptSalsa20(logs.title);
    // await RSA.decryptPKCS1v15(logs.title, adminPrivateKey);
    var rsaDecryptedDescription = decryptSalsa20(logs.description);
    // await RSA.decryptPKCS1v15(logs.description, adminPrivateKey);
    print('DecryptedTitle: $rsaDecryptedTitle');
    var vigenere = Vigenere('kripasik');
    String decryptedTitle = vigenere.decrypt(rsaDecryptedTitle);
    String decryptedDescription = vigenere.decrypt(rsaDecryptedDescription);
    print('DecryptedTitle: $decryptedTitle');

    final encryptedImage = logs.image;
    final decryptedImage = decryptFernet(encryptedImage);
    return UserLogs(
        title: decryptedTitle,
        description: decryptedDescription,
        image: decryptedImage,
        userEmail: logs.userEmail);
  }
}
