import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms/custom_widgets/widgets.dart';
import 'package:wms/models/user_logs.dart';
import 'package:wms/modules/http.dart' as http_module;
import 'package:wms/screens/user/add_response.dart';
import 'package:wms/screens/auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var email = '';
  @override
  void initState() {
    super.initState();
    getEmail();
  }

  List<UserLogs> logsList = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    getLogsList();
    return SafeArea(
      child: Scaffold(
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton.icon(
              style: const ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(Size(25, 60))),
              onPressed: () {
                Get.to(() => const AddLogScreen());
              },
              icon: const Icon(Icons.add_task_sharp),
              label: const Text('Add a New Log')),
        ),
        body: FutureBuilder<List<UserLogs>>(
          future: http_module.getAllLogsasAdmin(email),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('An error has occurred!'),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    title: Text(snapshot.data![index].title),
                    subtitle: Text(snapshot.data![index].description),
                    leading: Image.memory(Uint8List.fromList(const HexDecoder().convert(snapshot.data![index].image))),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    var localEmail = prefs.getString('email');
    setState(() {
      email = localEmail!;
    });
  }

  Future<String> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('name');
    return '$name';
  }

  Future getLogsList() async {
    var prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    var response = await http_module.getAllLogs(email!);
    if (response['success']) {
      // List<UserLogs> localLogsList = [];
      // for (var item in response['user']) {
      //   var id = item['id'];
      //   var title = item['title'];
      //   var description = item['description'];
      //   var image = item['image'];
      //   localLogsList.add(UserLogs(
      //       id: id,
      //       title: title,
      //       description: description,
      //       image: image,
      //       userEmail: email));
      // }
      // setState(() {
      //   logsList = localLogsList;
      // });
    }
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
}
