// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/global.dart';

final class Order {
  final String id;
  final String userId;
  final String storeId;
  final double totalPrice;
  final List<CartItem> items;
  final DateTime orderDate;
  final String status;
  final String address;

  Order({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.totalPrice,
    required this.items,
    required this.orderDate,
    required this.status,
    required this.address,
  });
}

class OrderData extends ChangeNotifier {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final firebase = FirebaseFirestore.instance;
  void addToOrder(Order order) async {
    try {
      var locationData =
          await firebase.collection('customers').doc(currentUserId).get();
      var latitude = locationData['latitude'];
      var longitude = locationData['longitude'];
      await ordersCollection.add({
        'id': order.id,
        'totalPrice': order.totalPrice,
        'userId': currentUserId,
        'orderDate': order.orderDate,
        'storeId': order.storeId,
        'status': 'قيد الإنتظار',
        'address': order.address,
        'latitude': latitude,
        'longitude': longitude,
        'items': order.items.map((item) {
          return {
            'id': item.id,
            'docId': item.docId,
            'prodId': item.prodId,
            'prodName': item.prodName,
            'prodPrice': item.prodPrice,
            'prodImgUrl': item.prodImgUrl,
            'quantity': item.quantity,
            'totalPrice': item.totalPrice,
          };
        }).toList(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error adding order: $e');
    }
  }

  Stream<QuerySnapshot> getOrdersStreamForUser(String userId) {
    return ordersCollection.where('userId', isEqualTo: userId).snapshots();
  }

  Future<List<Order>> getOrdersForStor(String sellerId) async {
    QuerySnapshot snapshot =
        await ordersCollection.where('storeId', isEqualTo: sellerId).get();

    List<Order> orders = [];
    snapshot.docs.forEach((doc) {
      orders.add(Order(
        id: doc.id,
        userId: doc['userId'],
        storeId: doc['storeId'],
        totalPrice: doc['totalPrice'],
        address: doc['address'] ?? "",
        items: (doc['items'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  docId: item['docId'],
                  sellerId: item['sellerId'],
                  prodId: item['prodId'],
                  prodName: item['prodName'],
                  prodImgUrl: item['prodImgUrl'],
                  prodPrice: item['prodPrice'],
                  quantity: item['quantity'],
                  totalPrice: item['totalPrice'],
                ))
            .toList(),
        orderDate: doc['orderDate'].toDate(),
        status: doc['status'],
      ));
    });

    return orders;
  }
}
