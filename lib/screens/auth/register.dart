import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms/custom_widgets/widgets.dart';
import 'package:wms/modules/http.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String response = "";
  String enteredName = '';
  String enteredEmail = '';
  String enteredPassword = '';
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomWidgets.getCustomHeaderText('Sign Up'),
                    const SizedBox(
                      height: 32,
                    ),
                    Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomWidgets.getCustomFormField((newValue) {
                            setState(() {
                              enteredName = newValue!;
                            });
                          }, enteredName, 'Name', 'name'),
                          const SizedBox(
                            height: 16,
                          ),
                          CustomWidgets.getCustomFormField((newValue) {
                            setState(() {
                              enteredEmail = newValue!;
                            });
                          }, enteredEmail, 'Email', 'email'),
                          const SizedBox(
                            height: 16,
                          ),
                          CustomWidgets.getCustomFormField((newValue) {
                            setState(() {
                              enteredPassword = newValue!;
                            });
                          }, enteredPassword, 'Password', 'password'),
                          const SizedBox(
                            height: 24,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                _saveActivity();
                              },
                              child: const Text('Sign Up')),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    ]);
  }

  void _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('saved');
      var res = await userRegister(enteredName, enteredEmail, enteredPassword);
      print('sent');
      if (res['success']) {
        Get.back();
      } else {
        Get.snackbar(
            "Failed", "Register new user is failed.\nPlease retry later");
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
