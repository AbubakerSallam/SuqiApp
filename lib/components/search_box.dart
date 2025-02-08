import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../utilities/natifications.dart';
import '../utilities/storage.dart';
import '../utilities/google_maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/main/product/details.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  SearchBoxState createState() => SearchBoxState();
}

class SearchBoxState extends State<SearchBox> {
  String? location;

  @override
  void initState() {
    var storage = SLocalStorage();
    location = storage.readData('address');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NatificationsScreen(),
                  ),
                );
              },
              child: const FaIcon(
                FontAwesomeIcons.bell,
                color: primaryColor,
                size: 24.1,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProductSearchResultsScreen()));
              },
              child: SizedBox(
                width: size.width / 1.35,
                child: TextFormField(
                  enabled: false,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            const ProductSearchResultsScreen()));
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(2),
                    prefixIcon: Icon(Icons.search, color: greyLite),
                    hintText: 'اكتب هنا ...',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        width: 0.001,
                        color: primaryColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        width: 2,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  MapScreen.routeName,
                );
              },
              child: FaIcon(
                FontAwesomeIcons.mapLocation,
                color: location == null ? Colors.red : primaryColor,
                size: 24.1,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}

class ProductSearchResultsScreen extends StatefulWidget {
  const ProductSearchResultsScreen({super.key});

  @override
  ProductSearchResultsScreenState createState() =>
      ProductSearchResultsScreenState();
}

class ProductSearchResultsScreenState
    extends State<ProductSearchResultsScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  void fetchAllProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        products = querySnapshot.docs
            .map((doc) => {
                  'id': doc,
                  'title': doc['title'],
                })
            .toList();
      });
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void fetchProducts(String searchText) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        products = querySnapshot.docs
            .where((doc) {
              String title = doc['title'].toLowerCase();
              List<String> searchWords = searchText.toLowerCase().split(' ');
              return searchWords.any((word) => title.contains(word));
            })
            .map((doc) => {
                  'id': doc,
                  'title': doc['title'],
                })
            .toList();
      });
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
                onChanged: (value) {
                  fetchProducts(value);
                },
                autofocus: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(2),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'اكتب هنا ...',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(
                      width: 0.201,
                      color: primaryColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(products[index]['title']),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              product: products[index]['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../constants/colors.dart';
// import '../utilities/google_maps.dart';
// import '../utilities/natifications.dart';
// import '../utilities/storage.dart';

// class SearchBox extends StatefulWidget {

//   const SearchBox({
//     super.key,
//   });

//   @override
//   State<SearchBox> createState() => _SearchBoxState();
// }

// class _SearchBoxState extends State<SearchBox> {
//   // String searchText = '';
//   // Stream<QuerySnapshot> productsStream = const Stream.empty();

//   // void onTextChanged(String searchText) {
//   //   setState(() {
//   //     productsStream = getProductsStream(searchText);
//   //     showProductStream = searchText.isNotEmpty;
//   //     // if (searchText.isEmpty) {
//   //     //   productsStream = Stream.empty();
//   //     //   showProductStream = false;
//   //     // } else {
//   //     //   showProductStream = true;
//   //     //   productsStream = getProductsStream(searchText);
//   //     // }
//   //   });
//   // }

//   // Stream<QuerySnapshot> getProductsStream(String searchText) {
//   //   return FirebaseFirestore.instance
//   //       .collection('products')
//   //       .where('title', isEqualTo: searchText)
//   //       .snapshots();
//   // }

//   // bool showProductStream = false;

//   String? location;
//   @override
//   void initState() {
//     var storage = SLocalStorage();
//     location = storage.readData('address');
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const NatificationsScreen(),
//                   ),
//                 );
//               },
//               child: const FaIcon(
//                 FontAwesomeIcons.bell,
//                 color: primaryColor,
//                 size: 24.1,
//               ),
//             ),
//             SizedBox(
//               width: size.width / 1.35,
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.all(2),
//                   prefixIcon: Icon(Icons.search, color: greyLite),
//                   hintText: 'اكتب هنا ...',
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(7),
//                     borderSide: const BorderSide(
//                       width: 0.001,
//                       color: primaryColor,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(9),
//                     borderSide: const BorderSide(
//                       width: 2,
//                       color: primaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pushNamed(
//                   MapScreen.routeName,
//                 );
//               },
//               child: FaIcon(
//                 FontAwesomeIcons.mapLocation,
//                 color: location == null ? Colors.red : primaryColor,
//                 size: 24.1,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 10.0,
//         ),
      
//       ],
//     );
//   }
// }
