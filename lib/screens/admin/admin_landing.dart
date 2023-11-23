import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms/constant/utils.dart';
import 'package:wms/custom_widgets/widgets.dart';
import 'package:wms/models/user_logs.dart';
import 'package:wms/modules/http.dart' as http_module;
import 'package:wms/screens/auth/login.dart';

class AdminLandingScreen extends StatefulWidget {
  const AdminLandingScreen({super.key});

  @override
  State<AdminLandingScreen> createState() => _AdminLandingScreenState();
}

class _AdminLandingScreenState extends State<AdminLandingScreen> {
  List<UserLogs> logsList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                removeSession(context);
              },
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(
              width: 24,
            )
          ],
          title: FutureBuilder<String>(
            future: getInfo(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Text('${snapshot.data}\'s working logbook');
              } else {
                return const Text('');
              }
            },
          )),
      body: FutureBuilder<List<UserLogs>>(
        future: http_module.getAllLogsasAdmin('admin@gmail.com'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => 
              Card(
                child: ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  // leading: Image.memory(snapshot.data![index].image),
                ),
              )
            ,);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void removeSession(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Card(
          color: Colors.deepOrange[100],
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidgets.getCustomHeaderText('Are you sure?'),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      print('token removed');
                      prefs.setBool('isLoggedIn', false);
                      print('isloggedin false');
                      Get.off(() => const LoginScreen());
                    },
                    child: const Text('Yes'),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('No'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<String> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('name');
    return '$name';
  }

//   Future<List<UserLogs>> fetchLogs(http.Client client) async {
//   final response = await client
//       .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

//   // Use the compute function to run parsePhotos in a separate isolate.
//   return compute(parsePhotos, response.body);
// }

//MAISH SALAH, MOTEDE AMBIL DATA MASI SALAH
  // Future<List<UserLogs>> getLogsListasAdmin() async {
  //   try {
  //     final parsedResponse = await getAllLogsasAdmin();
  //     if (parsedResponse['success']) {
  //       print('success lmao');
  //       print(parsedResponse.toString());
  //       List<UserLogs> localLogsList = parsedResponse
  //       // List<UserLogs> localLogsList = List.empty(growable: true);
  //       // List<UserLogs> logs = Utils.getLogsFromJSON(parsedResponse);
  //       // for (var log in logs) {
  //       //   final decryptedLog = await Utils.superDecryptasAdmin(log);
  //       //   localLogsList.add(decryptedLog);
  //       // }
  //       Iterable list = json.decode(parsedResponse['logs'].toString());
  //       if (list.isEmpty) {
  //         return;
  //       }
  //       setState(() {
  //         // logsList = list;
  //         logsList = list.map((model) => UserLogs.fromJson(model)).toList();
  //       });
  //     }
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }
}
