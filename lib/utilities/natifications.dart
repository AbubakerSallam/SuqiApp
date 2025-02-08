import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/models/global.dart';
import 'package:intl/intl.dart' as intl;

import '../components/loading.dart';
import '../constants/colors.dart';

class NatificationsScreen extends StatefulWidget {
  static const routeName = '/natifications-screen';

  const NatificationsScreen({super.key});

  @override
  State<NatificationsScreen> createState() => _NatificationsScreenState();
}

// class _NatificationsScreenState extends State<NatificationsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final firebase = FirebaseFirestore.instance;

//     Stream<QuerySnapshot> productStream = firebase
//         .collection('notifications')
//         .where('receiver', isEqualTo: currentUserId)
//         .orderBy('date', descending: true) // Order by date descending
//         .snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إشعاراتي'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: productStream,
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('حدث خطأ في جلب البيانات: ${snapshot.error}'),
//             );
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/sad.png',
//                     width: 150,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'لا إشعارات!',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                     ),
//                   )
//                 ],
//               ),
//             );
//           }

//           // Group notifications by date
//           Map<String, List<DocumentSnapshot>> groupedNotifications = {};
//           snapshot.data!.docs.forEach((doc) {
//             var date = intl.DateFormat.yMMMEd().format(doc['date'].toDate());
//             if (!groupedNotifications.containsKey(date)) {
//               groupedNotifications[date] = [];
//             }
//             groupedNotifications[date]!.add(doc);
//           });

//           return ListView.builder(
//             itemCount: groupedNotifications.length * 2 - 1, // Add separators
//             itemBuilder: (context, index) {
//               if (index.isOdd) {
//                 // Separator widget
//                 return const Divider(
//                   color: Colors.grey,
//                   height: 1,
//                   thickness: 1,
//                   indent: 20,
//                   endIndent: 20,
//                 );
//               }
//               var dateIndex = index ~/ 2;
//               var date = groupedNotifications.keys.toList()[dateIndex];
//               var notifications = groupedNotifications[date]!;
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Text(
//                       date,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: notifications.length,
//                     itemBuilder: (context, index) {
//                       var nati = notifications[index];
//                       return Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Card(
//                           elevation: 4.0,
//                           color: Colors.white,
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.only(
//                               left: 10,
//                               right: 10,
//                               top: 5,
//                             ),
//                             title: Text(
//                               nati['sender'],
//                               style: const TextStyle(
//                                 fontSize: 16,
//                               ),
//                             ),
//                             subtitle: Text(nati['content']),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class _NatificationsScreenState extends State<NatificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseFirestore.instance;

    Stream<QuerySnapshot> productStream = firebase
        .collection('natifications')
        .where('receiver', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'إشعاراتي',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 1.0,
            vertical: 5,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.2,
            child: StreamBuilder<QuerySnapshot>(
              stream: productStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('حدث خطأ ما ): '),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Loading(
                      color: primaryColor,
                      kSize: 30,
                    ),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/sad.png',
                          width: 150,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'لا إشعارات!',
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        )
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var nati = snapshot.data!.docs[index];
                    var date =
                        intl.DateFormat.yMMMEd().format(nati['date'].toDate());
                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: Card(
                        elevation: 4.0,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 2,
                          ),
                          leading: Container(
                            color: Colors.white,
                            child: Text(
                              date,
                              // nati['date'].toString(),
                            ),
                          ),
                          title: Text(
                            nati['sender'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(nati['content']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
