import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class CustomWidgets {
  static Widget getCustomHeaderText(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget getCustomFormField(void Function(String?)? save,
      String onSavedString, String title, String type) {
    return SizedBox(
      width: 312,
      child: TextFormField(
        onSaved: save,
        validator: (value) {
          if (value == null || value.isEmpty || value.trim().length <= 1) {
            return 'Invalid input. Please fill the field';
          } else if (type == 'email' && !EmailValidator.validate(value)) {
            return 'Please enter valid email';
          } else if (type == 'password' && value.trim().length <= 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        },
        obscureText: type == 'password' || type == 'passwordLogin',
        minLines: type == 'logDescription' ? 8 : 1,
        maxLines: type == 'logDescription' ? 8 : 1,
        maxLength: type == 'logTitle' || type == 'email'
            ? 30
            : type == 'logDescription'
                ? 200
                : 40,
        decoration: InputDecoration(
            label: Text(title),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            )),
      ),
    );
  }
}
