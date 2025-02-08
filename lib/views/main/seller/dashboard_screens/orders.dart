// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/constants/colors.dart';
import 'package:suqi/models/global.dart';
import '../../../../helpers/notification_helper.dart';
import '../../../../utilities/google_maps.dart';
import '../../../../utilities/showMessage.dart';
import '../../customer/customer_info.dart';
import '../../product/details.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart' as fire;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/store_orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? userToken;
  String? username;
  // String? customerName;
  final firebase = fire.FirebaseFirestore.instance;
  fire.DocumentSnapshot? credential;
  fire.DocumentSnapshot? userCredential;
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Stream<QuerySnapshot> getOrdersStreamForUser(String userId) {
    return ordersCollection
        .where('storeId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  Future<bool> showEditOrdeOptions() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'تنبيه !!',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'تعديل الطلب ك جاهز؟',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'جاهز',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = getOrdersStreamForUser(currentUserId!);

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
          'طلباتي',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching orders: ${snapshot.error ?? "Unknown error"}',
              ),
            );
          } else {
            List<QueryDocumentSnapshot> ordersDocs = snapshot.data!.docs;
            if (ordersDocs.isEmpty) {
              return const Center(
                child: Text('لا طلبات لعرضها'),
              );
            } else {
              return ListView.builder(
                itemCount: ordersDocs.length,
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot order = ordersDocs[index];
                  var date = intl.DateFormat.yMMMEd()
                      .format(order['orderDate'].toDate());

                  return Card(
                    color: litePrimary,
                    elevation: 5,
                    child: ExpansionTile(
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => MapScreen(
                                latitude: order['latitude'],
                                longitude: order['longitude'],
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: litePrimary,
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            date.toString(),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12.0),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          IconButton(
                            onPressed: () async {
                              DocumentSnapshot usersnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('customers')
                                      .doc(order['userId'])
                                      .get();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CustomerInfo(
                                    user: usersnapshot,
                                    location: order['address'],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.person_4_sharp,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          IconButton(
                            onPressed: () async {
                              bool ready = false;
                              if (order['status'] == 'قيد الإنتظار') {
                                ready = await showEditOrdeOptions();
                                if (ready == true) {
                                  FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(order.id)
                                      .update({"status": 'جاهز'});
                                  credential = await firebase
                                      .collection('customers')
                                      .doc(order['userId'])
                                      .get();
                                  userToken = credential!['userToken'];
                                  userCredential = await firebase
                                      .collection('sellers')
                                      .doc(currentUserId)
                                      .get();
                                  username = userCredential!['fullname'];
                                  if (mounted) {
                                    PushNotificationHelper.notificationFormat(
                                      userToken!,
                                      order['userId'],
                                      "تم تجهيز طلبك ",
                                      username!,
                                    );

                                    try {
                                      fire.FirebaseFirestore.instance
                                          .collection('natifications')
                                          .doc()
                                          .set({
                                        'notif_id': DateTime.now().toString(),
                                        'receiver': order['userId'],
                                        'sender': username,
                                        'content': "تم تجهيز طلبك من $username",
                                        'date': DateTime.now(),
                                      });
                                    } on fire.FirebaseException catch (e) {
                                      showSnackBar(
                                          'حدث خطأ ما ${e.message}', context);
                                    } catch (e) {
                                      {
                                        print('حدث خطأ ما  :)');
                                      }
                                    }
                                  }
                                  setState(() {});
                                }
                              } else {
                                showSnackBar('المنتج جاهز', context);
                              }
                            },
                            icon: Icon(
                              order['status'] == 'قيد الإنتظار'
                                  ? Icons.watch_later
                                  : Icons.mark_email_unread_outlined,
                              color: primaryColor,
                              // size: 21,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            '\$${order['totalPrice']}',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          Text(
                            '${order['status']}',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      iconColor: primaryColor,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: order['items'].length,
                          itemBuilder: (context, index) {
                            var subData = order['items'][index];
                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 5,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: primaryColor,
                                backgroundImage: NetworkImage(
                                  subData['prodImgUrl'],
                                ),
                              ),
                              title: Text(
                                subData['prodName'],
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text('\$${subData['totalPrice']}'),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  Text(
                                    'عدد : ${subData['quantity'].toString()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  DocumentSnapshot productSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('products')
                                          .doc(subData['docId'])
                                          .get();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        product: productSnapshot,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
