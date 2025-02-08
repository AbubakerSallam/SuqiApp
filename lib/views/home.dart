import 'package:flutter/material.dart';
import '../components/home_carousel.dart';
import '../components/search_box.dart';
import '../utilities/top_stores.dart';
import 'main/product_categories/clothes.dart';
import 'main/product_categories/jops.dart';
import 'main/product_categories/markat.dart';
import 'main/product_categories/others.dart';
import 'main/product_categories/resturants.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showProductStream = false;
  var currentTabIndex = 4;
  var categories = [
    'أخرى',
    'أدوية',
    'ماركات',
    'ملابس',
    'مطاعم',
  ];

  final categoriesList = const [
    Others(),
    Mediens(),
    SuperMarkets(),
    Clothes(),
    Resturants(),
  ];

  Widget kText(String text, int index) {
    return GestureDetector(
      onTap: () => setState(() {
        currentTabIndex = index;
      }),
      child: Padding(
        padding: const EdgeInsets.only(left: 33.0),
        child: Text(
          text,
          style: TextStyle(
            color: currentTabIndex == index ? Colors.black : Colors.grey,
            fontSize: currentTabIndex == index ? 19 : 12,
            fontWeight:
                currentTabIndex == index ? FontWeight.bold : FontWeight.w500,
          ),
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: const SearchBox(),
            ),
            const SizedBox(height: 5),
            const BannerWidget(),
            const SizedBox(height: 5),
            const TopStoresWidget(),
            const SizedBox(height: 10),
            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) =>
                    kText(categories[index], index),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.40,
              child: Column(
                children: [
                  categoriesList[currentTabIndex],
                  const SizedBox(
                    height: 10,
                  ),
                  //  const Text('بقية المنتجات ستتوفر قريبا...')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
