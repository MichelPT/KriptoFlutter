import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms/constant/utils.dart';
import 'package:multi_cipher/multi_cipher.dart';
import 'package:wms/models/user_logs.dart';

Future userLogin(String email, String password) async {
  var passBytes = utf8.encode(password);
  var digestedPass = sha512.convert(passBytes);
  final prefs = await SharedPreferences.getInstance();
  var privateKey = prefs.getString('${email}privatekey');
  print(privateKey);
  final response = await http.post(Uri.http(Utils.baseUrl, Utils.login),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Accept": "Application/json"
      },
      body: {
        'email': email,
        'password': digestedPass.toString()
      });
  print(digestedPass.toString());
  var decodedData = jsonDecode(response.body);
  return decodedData;
}

Future getAdminPublicKey() async {
  const email = 'admin@gmail.com';
  final response = await http.post(Uri.http(Utils.baseUrl, Utils.getAdminKey),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Accept": "Application/json"
      },
      body: {
        'email': email
      });
  var decodedData = jsonDecode(response.body);
  return decodedData;
}

Future userRegister(String username, String email, String password) async {
  var passBytes = utf8.encode(password);
  var digestedPass = sha512.convert(passBytes);
  var keyPair = await RSA.generate(2048);
  final prefs = await SharedPreferences.getInstance();
  var publicKey = keyPair.publicKey.toString();
  var privateKey = keyPair.privateKey.toString();
  if (!prefs.containsKey(email)) {
    prefs.setString('${email}privatekey', privateKey);
  }
  final response =
      await http.post(Uri.http(Utils.baseUrl, Utils.register), headers: {
    "Access-Control-Allow-Origin": "*",
    "Accept": "Application/json"
  }, body: {
    'name': username,
    'email': email,
    'password': digestedPass.toString(),
    'public_key': publicKey
  });
  var decodedData = jsonDecode(response.body);
  return decodedData;
}

Future uploadLogs(
    String title, String description, String image, String email) async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(email) && email != 'admin@gmail.com') {
    var keyPair = await RSA.generate(2048);
    prefs.setString(email, keyPair.privateKey);
  }

  final encryptedLog = await Utils.logEncryption(UserLogs(title: title, description: description, image: image, userEmail: email));

  final response =
      await http.post(Uri.http(Utils.baseUrl, Utils.logs), headers: {
    "Access-Control-Allow-Origin": "*",
    "Accept": "Application/json"
  }, body: {
    'title': encryptedLog.title,
    'description': encryptedLog.description,
    'image': encryptedLog.image,
    'email': email
  });
  var decodedData = jsonDecode(response.body);
  return decodedData;
}

Future getAllLogs(String email) async {
  var response = await http.post(Uri.http(Utils.baseUrl, Utils.allLogs),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Accept": "Application/json"
      },
      body: {
        'email': email
      });
  var decodedData = jsonDecode(response.body);
  return decodedData;
}

Future<List<UserLogs>> getAllLogsasAdmin(String email) async {
  late Response response;
  if (email == 'admin@gmail.com') {
    response = await http.get(
      Uri.http(Utils.baseUrl, Utils.allLogsAdmin),
      headers: {"Access-Control-Allow-Origin": "*"},
    );
  } else {
    response = await http.post(Uri.http(Utils.baseUrl, Utils.allLogs),
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Accept": "Application/json"
        },
        body: {
          'email': email
        });
  }
  print('response body: ${response.body.toString()}');
  var logs = jsonDecode(response.body);
  var data = jsonEncode(logs['logs']);
  final parsed = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
  print('parsed: ${parsed.toString()}');
  var userLogs =
      parsed.map<UserLogs>((json) => UserLogs.fromJson(json)).toList();
  var decryptedLogs = <UserLogs>[];
  for (var log in userLogs) {
    final decryptedLog = await Utils.superDecryptasAdmin(log);
    decryptedLogs.add(decryptedLog);
  }
  return decryptedLogs;
}

// Future<List<UserLogs>> parseList(dynamic responseBody) async {
//   final parsed =
//       (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();

//   print('parsed: ${parsed.toString()}');
//   var userLogs =
//       parsed.map<UserLogs>((json) => UserLogs.fromJson(json)).toList();
//   var decryptedLogs = <UserLogs>[];
//   for (var log in userLogs) {
//     final decryptedLog = await Utils.superDecryptasAdmin(log);
//     decryptedLogs.add(decryptedLog);
//   }
//   return decryptedLogs;
// }
