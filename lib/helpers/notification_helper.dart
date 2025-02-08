// // ignore_for_file: use_build_context_synchronously, avoid_print
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:suqi/models/global.dart';

import '../constants/colors.dart';
import '../main.dart';

class PushNotificationHelper {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isDialogOpen = false;

  static initialize(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground!');
      if (message.notification != null) {
        PushNotificationHelper().handleNotification(message.data, context);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from background notification!');
      if (message.notification != null) {
        PushNotificationHelper().handleNotification(message.data, context);
      }
    });
  }

  void handleNotification(Map<String, dynamic> data, context) {
    String receiverId = data['userID'];
    String senderId = data['senderID'];

    if (!isDialogOpen) {
      openNotification(receiverId, senderId, context);
    }
  }

  Future<void> openNotification(
      String receiverId, String senderId, context) async {
    try {
      isDialogOpen = true;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(senderId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? userData =
            snapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          String name = userData['fullname'].toString();
          String location = userData['address'].toString();
          String number = userData['phone'].toString();
          showDialog(
            context: context,
            builder: (context) {
              return notificationDialog(name, location, number, context);
            },
          ).then((_) {
            isDialogOpen = false;
          });
        }
      }
    } catch (e) {
      isDialogOpen = false;
      print('Error fetching data: $e');
    }
  }

  Widget notificationDialog(
      String name, String location, String number, context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        textDirection: TextDirection.rtl,
        "لديك اشعار جديد من  : $name",
        style: const TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            textDirection: TextDirection.rtl,
            "رقمه : $number",
            style: const TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            textDirection: TextDirection.rtl,
            "عنوانه : $location",
            style: const TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
          ),
          onPressed: () {
            Navigator.pop(navigatorKey.currentContext!);
          },
          child: const Text(
            'تم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> notificationFormat(String userToken, String receiverId,
      String type, String senderName) async {
    try {
      Map<String, String> headerNotification = {
        "Content-Type": "application/json",
        "Authorization": fcmServerToken,
      };
      Map bodyNotification = {
        "body": " $type  من $senderName إضغط لتراه",
        "title": "$type جديد!",
      };
      Map dataMap = {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "userID": receiverId,
        "senderID": currentUserId,
      };
      Map notificationOfficialFormat = {
        "notification": bodyNotification,
        "data": dataMap,
        "priority": "high",
        "to": userToken,
      };
      http.Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(notificationOfficialFormat),
      );
      print('Notification sent. Response code: ${response.statusCode}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> generateDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      String? deviceToken = await messaging.getToken();
      await FirebaseFirestore.instance
          .collection("customers")
          .doc(currentUserId)
          .update({
        "userToken": deviceToken,
      });
    } catch (e) {
      print('Error generating device token: $e');
    }
  }

  static Future<void> generateSellerToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      String? deviceToken = await messaging.getToken();
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(currentUserId)
          .update({
        "userToken": deviceToken,
      });
    } catch (e) {
      print('Error generating device token: $e');
    }
  }
}


// class PushNotificationHelper {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   Future<void> whenNotificationReceived(BuildContext context) async {
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) {
//         openNotification(
//             message.data["userID"], message.data["senderID"], context);
//       }
//     });

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         // Handle foreground notifications here if needed
//         // Navigator.of(context).push(
//         //   MaterialPageRoute(
//         //     builder: (context) => const NatificationsScreen(),
//         //   ),
//         // );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => const NatificationsScreen(),
//         ),
//       );
//       openNotification(
//           message.data["userID"], message.data["senderID"], context);
//     });
//   }

//   // Future<void> whenNotificationReceived(BuildContext context) async {
//   //   FirebaseMessaging.instance
//   //       .getInitialMessage()
//   //       .then((RemoteMessage? remoteMessage) {
//   //     if (remoteMessage != null) {
//   //       openNotification(remoteMessage.data["userID"],
//   //           remoteMessage.data["senderID"], context);
//   //     }
//   //   });
//   //   // FirebaseMessaging.onMessageOpenedApp.listen((event) {
//   //   //   FirebaseMessaging.instance
//   //   //       .getInitialMessage()
//   //   //       .then((RemoteMessage? remoteMessage) {
//   //   //     if (remoteMessage != null) {
//   //   //       openNotification(remoteMessage.data["userID"],
//   //   //           remoteMessage.data["senderID"], context);
//   //   //     }
//   //   //   });
//   //   // });
//   // }

//   Future<void> openNotification(
//       String receiverId, String senderId, BuildContext context) async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('customers')
//           .doc(senderId)
//           .get();
//       if (snapshot.exists) {
//         Map<String, dynamic>? userData =
//             snapshot.data() as Map<String, dynamic>?;

//         if (userData != null) {
//           String name = userData['fullname'].toString();
//           String location = userData['address'].toString();
//           String number = userData['phone'].toString();

//           showDialog(
//             context: context,
//             builder: (context) {
//               return notificationDialog(name, location, number, context);
//             },
//           );
//         } else {
//           print('User data is null');
//         }
//       } else {
//         print('Snapshot does not exist');
//       }
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }

//   Widget notificationDialog(name, location, number, context) {
//     return Dialog(
//       child: GridTile(
//         child: Padding(
//           padding: const EdgeInsets.all(3.0),
//           child: SizedBox(
//             height: 50.0,
//             child: Card(
//               color: primaryColor,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Center(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text("لديك اشعار جديد من : $name"),
//                       Text("رقمه : $number"),
//                       Text("عنوانه : $location"),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> notificationFormat(String userToken, String receiverId,
//       String type, String senderName) async {
//     try {
//       Map<String, String> headerNotification = {
//         "Content-Type": "application/json",
//         "Authorization": fcmServerToken,
//       };
//       Map bodyNotification = {
//         "body": " $type  من $senderName إضغط لتراه",
//         "title": "$type جديد!",
//       };
//       Map dataMap = {
//         "click_action": "FLUTTER_NOTIFICATION_CLICK",
//         "id": "1",
//         "status": "done",
//         "userID": receiverId,
//         "senderID": currentUserId,
//       };
//       Map notificationOfficialFormat = {
//         "notification": bodyNotification,
//         "data": dataMap,
//         "priority": "high",
//         "to": userToken,
//       };
//       http.Response response = await http.post(
//         Uri.parse("https://fcm.googleapis.com/fcm/send"),
//         headers: headerNotification,
//         body: jsonEncode(notificationOfficialFormat),
//       );
//       print('Notification sent. Response code: ${response.statusCode}');
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }

//   Future<void> generateDeviceToken() async {
//     try {
//       String? deviceToken = await messaging.getToken();
//       await FirebaseFirestore.instance
//           .collection("customers")
//           .doc(currentUserId)
//           .update({
//         "userToken": deviceToken,
//       });
//     } catch (e) {
//       print('Error generating device token: $e');
//     }
//   }

//   Future<void> generateSellerToken() async {
//     try {
//       String? deviceToken = await messaging.getToken();
//       await FirebaseFirestore.instance
//           .collection("sellers")
//           .doc(currentUserId)
//           .update({
//         "userToken": deviceToken,
//       });
//     } catch (e) {
//       print('Error generating device token: $e');
//     }
//   }
// }
