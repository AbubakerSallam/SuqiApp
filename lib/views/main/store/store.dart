import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../components/loading.dart';
import '../../../constants/colors.dart';
import 'store_details.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final Stream<QuerySnapshot> storeStream =
      FirebaseFirestore.instance.collection('sellers').snapshots();
  Stream<Map<String, dynamic>> getStoreRatingsStream(String storeId) {
    DocumentReference storeRatingsRef =
        FirebaseFirestore.instance.collection('sellers').doc(storeId);

    return storeRatingsRef.snapshots().map((snapshot) {
      return {
        'averageRating': snapshot.get('averageRating') ?? 0.0,
        'totalRatings': snapshot.get('totalRatings') ?? 0,
      };
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 38.0),
        child: Column(
          children: [
            const Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    color: primaryColor,
                  ),
                  Text(
                    'المتاجر',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: size.height / 1.25,
              child: StreamBuilder<QuerySnapshot>(
                stream: storeStream,
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
                    return Column(
                      children: [
                        Image.asset(
                          'assets/images/sad.png',
                          width: 150,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'لايوجد متاجر بعد!',
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        )
                      ],
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 2,
                    ),
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StoreDetails(
                                store: data,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 7.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          data['image'],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -3,
                                  right: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        data['fullname'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            data['address'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const FaIcon(
                                            FontAwesomeIcons.mapLocationDot,
                                            color: primaryColor,
                                            size: 14.1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                StreamBuilder<Map<String, dynamic>>(
                                  stream: getStoreRatingsStream(
                                      data.id), // Pass the store ID here
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Positioned(
                                        top: 10,
                                        left: 5,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star_border,
                                              color: Colors.grey,
                                              size: 24.1,
                                            ), // Empty emoji
                                            Text('0'),
                                          ],
                                        ),
                                      );
                                    }

                                    double averageRating =
                                        snapshot.data!['averageRating'] ?? 0.0;
                                    int totalRatings =
                                        snapshot.data!['totalRatings'] ?? 0;

                                    return Positioned(
                                      top: 10,
                                      left: 5,
                                      child: GestureDetector(
                                        onTap: () => {},
                                        child: Row(
                                          children: [
                                            totalRatings == 0
                                                ? const Icon(
                                                    Icons.star_border,
                                                    color: Colors.grey,
                                                    size: 24.1,
                                                  )
                                                : const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 24.1,
                                                  ),
                                            Text(
                                                '${averageRating.toString()} (${totalRatings.toString()})'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 10,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => {},
                                    child: CircleAvatar(
                                      backgroundColor: litePrimary,
                                      child: const Icon(
                                        Icons.store_outlined,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
