// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../constants/colors.dart';

// snackbar for error message
showSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        textDirection: TextDirection.rtl,
        message,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: primaryColor,
      // action: SnackBarAction(
      //   onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      //   label: 'إلغاء',
      //   textColor: Colors.white,
      // ),
    ),
  );
}
