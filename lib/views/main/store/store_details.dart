// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:suqi/models/global.dart';
import '../../../constants/colors.dart';
import '../../../utilities/products_stream_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utilities/showMessage.dart';
import 'package:geolocator/geolocator.dart';

class StoreDetails extends StatefulWidget {
  const StoreDetails({
    super.key,
    required this.store,
  });
  final dynamic store;

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  var userId;
  bool _isLoggedIn = false;
  double? distanceInKm;
  Future<void> calculateDistance() async {
    try {
      // Get store location
      DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.store.id)
          .get();
      // Get user's current location
      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double userLat = userPosition.latitude;
      double userLng = userPosition.longitude;

      if (_isLoggedIn) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .doc(currentUserId)
            .get();
        userLat = userSnapshot['latitude'];
        userLng = userSnapshot['longitude'];
      }

      if (storeSnapshot.exists) {
        double storeLat = storeSnapshot['latitude'];
        double storeLng = storeSnapshot['longitude'];

        // Calculate distance
        double distance =
            Geolocator.distanceBetween(userLat, userLng, storeLat, storeLng);

        setState(() {
          distanceInKm = distance / 1000; // Convert meters to kilometers
          // isLoading = false;
        });
      }
    } catch (e) {
      print("Error calculating distance: $e");
      setState(() {
        // isLoading = false;
      });
    }
  }

  Future<void> checkUserLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
        });
      }
    }
  }

  void placeCall() {
    // TODO: Implement placeCall
    if (kDebugMode) {
      print(widget.store['phone']);
    }
  }

  void sendMail() {
    // TODO: Implement sendMail
    if (kDebugMode) {
      print(widget.store['email']);
    }
  }

  void sendWhatsappMsg() {
    // TODO: Implement sendWhatsappMsg
    if (kDebugMode) {
      print('sendWhatsappMsg');
    }
  }

  void saveUserRating(double userRating, String storeId, String userId) {
    DocumentReference storeRatingsRef =
        FirebaseFirestore.instance.collection('store_ratings').doc(storeId);

    DocumentReference userRatingRef =
        storeRatingsRef.collection('user_ratings').doc(userId);

    userRatingRef.set({
      'userId': userId,
      'rating': userRating,
      'timestamp': DateTime.now(),
    }).then((value) {
      print('User rating saved successfully!');
      updateStoreRatings(storeId);
    }).catchError((error) {
      print('Failed to save user rating: $error');
    });
  }

  void updateStoreRatings(String storeId) {
    DocumentReference storeRatingsRef =
        FirebaseFirestore.instance.collection('store_ratings').doc(storeId);

    storeRatingsRef.collection('user_ratings').get().then((querySnapshot) {
      int totalRatings = querySnapshot.docs.length;
      double sumRatings = 0;

      querySnapshot.docs.forEach((ratingDoc) {
        var ratingData = ratingDoc.data();
        double rating = ratingData['rating'] ?? 0;
        sumRatings += rating;
      });

      double averageRating = totalRatings > 0 ? sumRatings / totalRatings : 0;

      FirebaseFirestore.instance
          .collection('sellers')
          .doc(storeId)
          .get()
          .then((storeDoc) {
        if (storeDoc.exists) {
          storeDoc.reference.update({
            'averageRating': averageRating,
            'totalRatings': totalRatings,
          }).then((value) {
            print('Store ratings updated successfully!');
          }).catchError((error) {
            print('Failed to update store ratings: $error');
          });
        } else {
          FirebaseFirestore.instance.collection('sellers').doc(storeId).set({
            'averageRating': averageRating,
            'totalRatings': totalRatings,
          }).then((value) {
            print('Store ratings initialized successfully!');
          }).catchError((error) {
            print('Failed to initialize store ratings: $error');
          });
        }
      }).catchError((error) {
        print('Error getting store document: $error');
      });
    }).catchError((error) {
      print('Error getting user ratings: $error');
    });
  }

  void _showRatingDialog(String storeId, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double userRating = 3;

        return AlertDialog(
          title: const Text("تقييم المتجر"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 1.1,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                  userRating = rating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveUserRating(userRating, storeId, userId);
                Navigator.of(context).pop();
              },
              child: const Text("موافق"),
            ),
          ],
        );
      },
    );
  }

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
  void initState() {
    calculateDistance();
    super.initState();
    checkUserLogin();
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    userId = user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    var store = widget.store;
    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('seller_id', isEqualTo: store.id)
        .snapshots();

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomSheet: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    onPressed: () => sendWhatsappMsg(),
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'واتساب',
                      style: TextStyle(
                        color: Colors.white,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    onPressed: () => placeCall(),
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'اتصل',
                      style: TextStyle(
                        color: Colors.white,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    onPressed: () => sendMail(),
                    icon: const Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'ايميل',
                      style: TextStyle(
                        color: Colors.white,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                size: 35,
                color: primaryColor,
              ),
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18.0),
            child: Icon(
              Icons.storefront,
              color: primaryColor,
              size: 35,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height / 3.5,
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(store['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    store['fullname'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<Map<String, dynamic>>(
                        stream: getStoreRatingsStream(
                            store.id), // Pass the store ID here
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return GestureDetector(
                              onTap: () {
                                _showRatingDialog(store.id, userId);
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.star_border,
                                      color: Colors.grey), // Empty emoji
                                  Text('0'),
                                ],
                              ),
                            );
                          }

                          double averageRating =
                              snapshot.data!['averageRating'] ?? 0.0;
                          int totalRatings =
                              snapshot.data!['totalRatings'] ?? 0;

                          return GestureDetector(
                            onTap: () => _showRatingDialog(store.id, userId),
                            child: Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: averageRating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 1,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  itemBuilder: (context, _) => GestureDetector(
                                    onTap: () {
                                      if (_isLoggedIn) {
                                        _showRatingDialog(store.id, userId);
                                      } else {
                                        showSnackBar(
                                            "يجب تسجيل الدخول أولا", context);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 1.1,
                                    ),
                                  ),
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                ),
                                const SizedBox(width: 2),
                                Text(
                                    '${averageRating.toString()} (${totalRatings.toString()})'),
                              ],
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Text(store['address']),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.location_pin,
                            color: primaryColor,
                            size: 21.1,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(distanceInKm != null
                              ? 'يبعد : ${distanceInKm!.toStringAsFixed(2)} كم عنك'
                              : 'يبعد ...'),
                          const SizedBox(
                            width: 10,
                          ),
                          // const Icon(
                          //   Icons.car_rental,
                          //   color: primaryColor,
                          //   size: 21.1,
                          // ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(store['hours']),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.timelapse_outlined,
                            color: primaryColor,
                            size: 21.1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height / 1,
              child: ProductStreamBuilder(
                productStream: productsStream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
