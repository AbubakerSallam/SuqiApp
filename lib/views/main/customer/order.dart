// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/constants/colors.dart';
import 'package:suqi/models/global.dart';
import '../../../utilities/google_maps.dart';
import '../product/details.dart';
import 'package:intl/intl.dart' as intl;

import '../store/store_details.dart';

class CustomerOrderScreen extends StatefulWidget {
  static const routeName = '/customer_orders';

  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Stream<QuerySnapshot> getOrdersStreamForUser(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = getOrdersStreamForUser(currentUserId!);

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
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 21,
                          ),
                          IconButton(
                            onPressed: () async {
                              DocumentSnapshot storesnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('sellers')
                                      .doc(order['storeId'])
                                      .get();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StoreDetails(
                                    store: storesnapshot,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.store_outlined,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            '${order['totalPrice']}',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
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
                                  Text('${subData['totalPrice']}'),
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
