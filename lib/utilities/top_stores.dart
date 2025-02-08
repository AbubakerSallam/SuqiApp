import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/loading.dart';
import '../constants/colors.dart';
import '../views/main/store/store_details.dart';

class TopStoresWidget extends StatelessWidget {
  const TopStoresWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .orderBy('totalRatings', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(); // Return an empty container if there are no stores or an error occurs
        }
        return Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllStoresScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(
                  textDirection: TextDirection.ltr,
                  'أفضل المتاجر',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
                height: 10), // Space between header and store profiles
            SizedBox(
              height: 50, // Fixed height for the horizontal ListView
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var store = snapshot.data!.docs[index];
                  return StoreItemWidget(
                    store: store,
                    storeName: store['fullname'],
                    totalRatings: store['totalRatings'],
                    imageUrl: store[
                        'image'], // Assuming 'image' is the field storing the store picture URL
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ignore: must_be_immutable
class StoreItemWidget extends StatelessWidget {
  final String storeName;
  final int totalRatings;
  final String imageUrl;
  // ignore: prefer_typing_uninitialized_variables
  var store;

  StoreItemWidget({
    super.key,
    required this.storeName,
    this.store,
    required this.totalRatings,
    required this.imageUrl,
  });
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StoreDetails(
            store: store,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 10, left: 10),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(imageUrl),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textDirection: TextDirection.ltr,
                  storeName,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<Map<String, dynamic>>(
                  stream:
                      getStoreRatingsStream(store.id), // Pass the store ID here
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
                              size: 14.1,
                            ), // Empty emoji
                            Text('0'),
                          ],
                        ),
                      );
                    }

                    double averageRating =
                        snapshot.data!['averageRating'] ?? 0.0;
                    int totalRatings = snapshot.data!['totalRatings'] ?? 0;

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
                                    size: 14.1,
                                  )
                                : const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14.1,
                                  ),
                            Text(
                                '${averageRating.toString()} (${totalRatings.toString()})'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  final Stream<QuerySnapshot> storeStream = FirebaseFirestore.instance
      .collection('sellers')
      .orderBy('totalRatings', descending: true)
      .snapshots();

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 38.0),
          child: Column(
            children: [
              const Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'الأكثر تقييما',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.star,
                      color: primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: size.height / 1,
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
                        mainAxisSpacing: 0.10,
                        crossAxisSpacing: 1,
                      ),
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StoreDetails(
                                  store: data,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
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
                                      height: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            data['image'],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                          snapshot.data!['averageRating'] ??
                                              0.0;
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
                                    bottom: 3,
                                    right: 12,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
      ),
    );
  }
}
