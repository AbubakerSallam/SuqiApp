import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../constants/colors.dart';

class CustomerInfo extends StatelessWidget {
  static const routeName = '/customer-info';

  const CustomerInfo({
    super.key,
    required this.user,
    required location,
  });

  final DocumentSnapshot user;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'معلومات العميل',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 23.0, top: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextWithDivider('الإسم : ${user['fullname']}'),
            const SizedBox(height: 10),
            buildTextWithDivider('إيميل : ${user['email']}'),
            const SizedBox(height: 10),
            buildTextWithDivider('الرقم : ${user['phone']}'),
            const SizedBox(height: 10),
            buildTextWithDivider('العنوان : ${user['address']}'),
            const SizedBox(height: 10),
            buildTextWithDivider('العنوان في الطلب : $Widget.locatin'),
            const SizedBox(height: 10),
            // Text(
            //   'تاريخ الدخول: ${intl.DateFormat.yMMMEd().format(user['registrationDate'].toDate())}',
            //   style: TextStyle(fontSize: 16),
            // ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  Widget buildTextWithDivider(String text) {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: primaryColor, // Change text color here
            ),
          ),
          const WidgetSpan(
            child: Divider(
              color: Colors.black,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
