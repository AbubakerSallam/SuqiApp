import 'package:flutter/material.dart';
import '../../../utilities/products_stream_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Resturants extends StatelessWidget {
  const Resturants({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final firestore = FirebaseFirestore.instance;

    final Stream<QuerySnapshot> productStream = firestore
        .collection('products')
        .where('category', isEqualTo: 'مطاعم')
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
/*
 productStream.isEmpty ==true
              ?Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/sp2.png',
                width: 250,
              ),
              const SizedBox(height: 10),
              const Text(
                'تبا! لايوجد شيء لعرضه',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                ),
              )
            ],
          )
              :
*/