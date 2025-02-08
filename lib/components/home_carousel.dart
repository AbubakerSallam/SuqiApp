// ignore_for_file: avoid_function_literals_in_foreach_calls
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../views/main/store/store_details.dart';
import '../../components/loading.dart';
import '../../constants/colors.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});
  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int scrollPosition = 0;
  final List<String> slides = [
    'assets/images/logo.png',
  ];
  final List _bannerImage = [];
  final List _storeDocs = [];
  getBanners() async {
    await FirebaseFirestore.instance
        .collection('ads')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _storeDocs.add(doc['seller_id']);
          _bannerImage.add(doc['image']);
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getBanners();
    // fetchAds();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchAds() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('customers').get();
    _bannerImage.clear();
    _storeDocs.clear();
    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data();
      var imageUrl = data['image'];
      var storeId = data['seller_id'];
      _bannerImage.add(imageUrl);
      _storeDocs.add(storeId);
    });

    setState(() {});
  }

  Stream<QuerySnapshot> getStoreStreamById(String storeId) {
    return FirebaseFirestore.instance
        .collection('sellers')
        .where('owner-id', isEqualTo: storeId)
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Object?>>> getStoreStream(String storeId) async {
    return FirebaseFirestore.instance
        .collection('sellers')
        .where('owner-id', isEqualTo: storeId)
        .snapshots();
  }

  navigateToStoreDetails(String storeId) async {
    Stream<QuerySnapshot> storeStream = await getStoreStream(storeId);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StreamBuilder<QuerySnapshot>(
            stream: storeStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                // Handle error
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading indicator
                // return CircularProgressIndicator();
                return const Center(
                  child: Loading(
                    color: primaryColor,
                    kSize: 70,
                  ),
                );
              }

              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                // Handle case when data is null or empty
                return const Center(
                  child: Loading(
                    color: primaryColor,
                    kSize: 70,
                  ),
                );
              }

              var storeData = snapshot.data!.docs.first;
              return StoreDetails(
                store: storeData,
              );
            },
          ),
        ),
      );
    }
  }

  Widget kSlideContainer(String imgUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imgUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              color: Colors.grey.shade200,
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: _bannerImage.isEmpty
                  ? PageView.builder(
                      itemCount: slides.length,
                      itemBuilder: (BuildContext context, int index) {
                        return kSlideContainer(slides[index]);
                      },
                    )
                  : PageView.builder(
                      itemCount: _bannerImage.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
                            await navigateToStoreDetails(
                                _storeDocs[index].toString());
                          },
                          child: CachedNetworkImage(
                            imageUrl: _bannerImage[index],
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                              height: 140,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        );
                      },
                      onPageChanged: (val) {
                        setState(() {
                          scrollPosition = val;
                        });
                      },
                    ),
            ),
          ),
        ),
        _bannerImage.isEmpty
            ? Container()
            : Positioned(
                bottom: 10.0,
                child: DotsIndicatorWidget(
                  scrollPosition: scrollPosition,
                  itemList: _bannerImage,
                ),
              )
      ],
    );
  }
}

class DotsIndicatorWidget extends StatelessWidget {
  const DotsIndicatorWidget({
    super.key,
    required this.scrollPosition,
    required this.itemList,
  });

  final int scrollPosition;
  final List itemList;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DotsIndicator(
            position: scrollPosition,
            dotsCount: itemList.length,
            decorator: DotsDecorator(
                activeColor: Colors.blue.shade900,
                spacing: const EdgeInsets.all(2),
                size: const Size.square(6),
                activeSize: const Size(12, 6),
                activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
          ),
        ),
      ],
    );
  }
}
