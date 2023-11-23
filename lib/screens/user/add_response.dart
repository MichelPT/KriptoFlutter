import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:responsive_sizer/responsive_sizer.dart' as responsive_sizer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms/custom_widgets/widgets.dart';
import 'package:wms/modules/http.dart';
import 'package:wms/screens/user/home.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final picker = ImagePicker();
  final logFormKey = GlobalKey<FormState>();
  String enteredTitle = '';
  String enteredDescription = '';
  dynamic image, hex;

  @override
  Widget build(BuildContext context) {
    final Widget textForms = Column(
      children: [
        SizedBox(
          height: 10.h,
        ),
        CustomWidgets.getCustomFormField((newValue) {
          setState(() {
            enteredTitle = newValue!;
          });
        }, enteredTitle, 'Title', 'logTitle'),
        SizedBox(
          height: 5.h,
        ),
        CustomWidgets.getCustomFormField((newValue) {
          setState(() {
            enteredDescription = newValue!;
          });
        }, enteredDescription, 'Description', 'logDescription')
      ],
    );
    final Widget imageUpload = Column(
      children: [
        const Text(
          'Please input your image with the following conditions:\n1. It can prove your work hence it needs to be related to it\n2. It is mandatory to have date and time to be in the image\n3. Please avoid using innapropriate images or photos',
        ),
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
            width: 20.w,
            height: 20.h,
            child: image == null
                ? Image.asset('assets/images/no_image.png')
                : Image.memory(image)),
        ElevatedButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text('Add an image')),
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: CustomWidgets.getCustomHeaderText('Add New Logs'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: logFormKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: responsive_sizer.Device.screenType ==
                            responsive_sizer.ScreenType.mobile
                        ? [
                            textForms,
                            imageUpload,
                            SizedBox(
                              height: 5.h,
                            ),
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.amber[700]),
                                    minimumSize: MaterialStateProperty.all(
                                        Size(7.w, 8.h))),
                                icon: const Icon(Icons.file_upload_rounded),
                                onPressed: uploadNewLog,
                                label: const Text('Upload Log'))
                          ]
                        : [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                textForms,
                                imageUpload,
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.amber[700]),
                                    minimumSize: MaterialStateProperty.all(
                                        Size(7.w, 8.h))),
                                icon: const Icon(Icons.file_upload_rounded),
                                onPressed: uploadNewLog,
                                label: const Text('Upload Log'))
                          ])),
          ),
        ),
      ),
    );
  }

  void uploadNewLog() async {
    if (logFormKey.currentState!.validate() && image != null) {
      logFormKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      var email = prefs.getString('email')!;
      var res = await uploadLogs(enteredTitle, enteredDescription, hex, email);
      if (res['success']) {
        Fluttertoast.showToast(msg: 'Log has been successfully uploaded');
        Get.offAll(() => const HomeScreen());
      } else {
        Fluttertoast.showToast(msg: 'Upload log failed', textColor: Colors.red);
      }
    }
  }

  Future<void> pickImage() async {
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      List<int> bytes = await file.readAsBytes();
      hex = const HexEncoder().convert(bytes);
      setState(() {
        image = bytes;
      });
    }
  }

  // Future<void> pickImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile == null) return;
  //   setState(() {
  //     image = File(pickedFile.path);
  //   });
  // }
}
