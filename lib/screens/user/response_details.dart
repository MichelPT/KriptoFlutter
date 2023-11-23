import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms/custom_widgets/widgets.dart';
import 'package:wms/models/user_logs.dart';

class LogDetails extends StatelessWidget {
  const LogDetails({super.key, required this.userLog});

  final UserLogs userLog;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: CustomWidgets.getCustomHeaderText('${userLog.userEmail} Log'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 5.h,
                ),
                Image.memory(Uint8List.fromList(
                    const HexDecoder().convert(userLog.image))),
                SizedBox(
                  height: 5.h,
                ),
                CustomWidgets.getCustomHeaderText(userLog.title),
                SizedBox(
                  height: 5.h,
                ),
                Text(userLog.description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
