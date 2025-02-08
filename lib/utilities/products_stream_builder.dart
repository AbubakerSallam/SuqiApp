// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suqi/models/global.dart';
import 'package:suqi/utilities/showMessage.dart';
import '../models/cart.dart';
import '../components/loading.dart';
import '../constants/colors.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../views/main/product/details.dart';

class ProductStreamBuilder extends StatefulWidget {
  const ProductStreamBuilder({
    super.key,
    required this.productStream,
  });
  final Stream<QuerySnapshot<Object?>> productStream;

  @override
  State<ProductStreamBuilder> createState() => _ProductStreamBuilderState();
}

class _ProductStreamBuilderState extends State<ProductStreamBuilder> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  void toggleIsFav(String productId) async {
    final productRef =
        FirebaseFirestore.instance.collection('products').doc(productId);
    final userRef = productRef.collection('favorites').doc(currentUserId);

    final userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.delete();
    } else {
      await userRef.set({'currentUserId': currentUserId, 'favStatus': true});
    }
  }

  Future<bool> showClearCartOptions() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'تنبيه !!',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'المنتج من متجر اخر.. حذف محتويات السلة؟',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> checkUserLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      if (mounted) {
        setState(() {
          //  currentUserId = user;
          isLoggedIn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartData>(context, listen: false);
    // add to cart
    void addToCart(
      var docId,
      var prodId,
      var sellerId,
      var prodName,
      var prodPrice,
      var prodImgUrl,
    ) {
      cartData.addToCart(
        CartItem(
          id: '',
          docId: docId,
          prodId: prodId,
          sellerId: sellerId,
          prodName: prodName,
          prodPrice: double.parse(prodPrice),
          prodImgUrl: prodImgUrl,
          totalPrice: double.parse(prodPrice),
        ),
      );
    }

    void removeFromCart(var prodId) {
      cartData.removeFromCart(prodId);
    }

    return Consumer<CartData>(
      builder: (context, data, child) => StreamBuilder<QuerySnapshot>(
        stream: widget.productStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/sad.png',
                    width: 120,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'لا بيانات!',
                    style: TextStyle(
                      color: primaryColor,
                    ),
                  )
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      builder: (context) => DetailsScreen(
                        product: data,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(data['images'][0]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 5,
                          child: Text(
                            '${data['title']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 5,
                          child: Text(
                            'ريال ${data['price']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              if (isLoggedIn) {
                                toggleIsFav(data.id);
                                showSnackBar("تم ", context);
                                setState(() {});
                              } else {
                                showSnackBar("يجب تسجيل الدخول أولا", context);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: litePrimary,
                              child: currentUserId == null
                                  ? const Icon(Icons.favorite_border,
                                      color: Colors.redAccent)
                                  : StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('products')
                                          .doc(data.id)
                                          .collection('favorites')
                                          .doc(currentUserId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data?.exists == false) {
                                          return const Icon(
                                              Icons.favorite_border,
                                              color: Colors.redAccent);
                                        } else {
                                          return const Icon(Icons.favorite,
                                              color: Colors.redAccent);
                                        }
                                      },
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: () async {
                              bool deletCart;
                              if (cartData.isItemOnCart(data['prod_id'])) {
                                removeFromCart(data['prod_id']);
                              } else {
                                if (!cartData.isOtherStor(data['seller_id']) &&
                                    cartData.cartItemCount > 0) {
                                  // ignore: await_only_futures
                                  deletCart = await showClearCartOptions();
                                  if (deletCart == true) {
                                    cartData.clearCart();
                                    addToCart(
                                      data.id,
                                      data['prod_id'],
                                      data['seller_id'],
                                      data['title'],
                                      data['price'],
                                      data['images'][0],
                                    );
                                    if (!mounted) {
                                      showSnackBar('حدث خطأ ما!', context);

                                      return;
                                    }
                                    if (mounted) {
                                      showSnackBar(
                                          "تم حذف المنتج و إستبداله ", context);
                                    }
                                  }
                                } else {
                                  addToCart(
                                    data.id,
                                    data['prod_id'],
                                    data['seller_id'],
                                    data['title'],
                                    data['price'],
                                    data['images'][0],
                                  );
                                }
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: litePrimary,
                              child: Icon(
                                cartData.isItemOnCart(data['prod_id'])
                                    ? Icons.shopping_cart
                                    : Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //   );
                // },
              );
            },
          );
        },
      ),
    );
  }
}
