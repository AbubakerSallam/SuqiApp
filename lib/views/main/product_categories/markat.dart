import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../utilities/products_stream_builder.dart';

class SuperMarkets extends StatelessWidget {
  const SuperMarkets({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final firestore = FirebaseFirestore.instance;

    final Stream<QuerySnapshot> productStream = firestore
        .collection('products')
        .where('category', isEqualTo: 'ماركات')
        .snapshots();

      return Column(
      children: [
        SizedBox(
            height: size.height / 1.5,
            child: ProductStreamBuilder(
              productStream: productStream,
            ))
      ],
    );
  }
}