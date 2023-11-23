import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms/custom_widgets/widgets.dart';
import 'package:wms/modules/http.dart';
import 'package:wms/screens/user/home.dart';
import 'package:wms/screens/auth/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String enteredEmail = '';
  String enteredPassword = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomWidgets.getCustomHeaderText('Login'),
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
                    }, enteredPassword, 'Password', 'passwordLogin'),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                        onPressed: loginUser, child: const Text('Login')),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            'Haven\'t got an account yet? Click here to'),
                        TextButton(
                            onPressed: () =>
                                Get.to(() => const RegisterScreen()),
                            child: const Text('Sign Up'))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var email = enteredEmail.trim();
      var res = await userLogin(email, enteredPassword.trim());
      if (res['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', res['user'][0]['name']);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', res['token']);
        prefs.setString('email', email);
        Get.off(() => const HomeScreen());
      } else {
        Get.snackbar('Login failed', 'Email and password are not valid');
      }
    }
  }
}
