// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/utilities/showMessage.dart';
import '../../../components/loading.dart';
import '../../../constants/colors.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:photo_view/photo_view.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import '../../../models/cart.dart';
import '../../../models/global.dart';
import '../../../providers/cart.dart';
import 'package:provider/provider.dart';
import '../store/store_details.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.product,
  });
  final dynamic product;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with TickerProviderStateMixin {
  bool isLoggedIn = false;
  int total = 0;
  var userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  Future<void> checkUserLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      if (mounted) {
        setState(() {
          //  userId = user;
          isLoggedIn = true;
        });
      }
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

  void showImageBottom() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) => SizedBox(
        height: 500,
        child: CarouselSlider.builder(
          itemCount: widget.product['images'].length,
          itemBuilder: (context, index, i) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '${index + 1}/${widget.product['images'].length}',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  child: Image.network(
                    widget.product['images'][index],
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          options: CarouselOptions(
            viewportFraction: 1,
            aspectRatio: 1.5,
            height: 500,
            autoPlay: true,
          ),
        ),
      ),
    );
  }

  // toggle isFav
  void toggleIsFav(String productId, String userId) async {
    final productRef =
        FirebaseFirestore.instance.collection('products').doc(productId);
    final userRef = productRef.collection('favorites').doc(userId);

    final userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.delete();
    } else {
      await userRef.set({'userId': userId, 'favStatus': true});
    }
  }

  DocumentSnapshot? store;

  _fetchStore() async {
    var details = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.product['seller_id'])
        .get();
    store = details;
    // setState(() {
    // });
  }

  // navigate to store
  void navigateToStore() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoreDetails(store: store),
      ),
    );
  }

  Animation<double>? _animation;
  AnimationController? _animationController;
  var isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      );

      final curvedAnimation = CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _animationController!,
      );
      _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

      _fetchStore();
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartData>(context, listen: false);
    var userId = FirebaseAuth.instance.currentUser?.uid;

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
      setState(() {});
    }

    void removeFromCart(var prodId) {
      cartData.removeFromCart(prodId);
    }

    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );

    var product = widget.product;

    final Stream<QuerySnapshot> similarProducts = FirebaseFirestore.instance
        .collection('products')
        .where('seller_id', isEqualTo: product['seller_id'])
        // .where('sub_category', isEqualTo: product['sub_category'])
        // .where('prod_id', isNotEqualTo: product['prod_id'])
        .snapshots();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: cartData.isItemOnCart(widget.product['prod_id'])
                ? "حذف من السلة"
                : "إضافة للسلة",
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: cartData.isItemOnCart(widget.product['prod_id'])
                ? Icons.shopping_cart
                : Icons.shopping_cart_outlined,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            onPress: () async {
              bool deletCart;
              if (cartData.isItemOnCart(widget.product['prod_id'])) {
                removeFromCart(widget.product['prod_id']);
                setState(() {});
              } else {
                if (!cartData.isOtherStor(widget.product['seller_id']) &&
                    cartData.cartItemCount > 0) {
                  // ignore: await_only_futures
                  deletCart = await showClearCartOptions();
                  if (deletCart == true) {
                    cartData.clearCart();
                    addToCart(
                      widget.product.id,
                      widget.product['prod_id'],
                      widget.product['seller_id'],
                      widget.product['title'],
                      widget.product['price'],
                      widget.product['images'][0],
                    );
                    if (!mounted) {
                      showSnackBar('حدث خطأ ما!', context);

                      return;
                    }
                    if (mounted) {
                      showSnackBar("تم حذف المنتج و إستبداله ", context);
                    }
                  }
                } else {
                  addToCart(
                    widget.product.id,
                    widget.product['prod_id'],
                    widget.product['seller_id'],
                    widget.product['title'],
                    widget.product['price'],
                    widget.product['images'][0],
                  );
                }
              }
              _animationController!.reverse();
            },
          ),
          Bubble(
            title: "المتجر",
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.storefront,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            onPress: () {
              navigateToStore();
              _animationController!.reverse();
            },
          ),
        ],
        animation: _animation!,
        onPress: () => _animationController!.isCompleted
            ? _animationController!.reverse()
            : _animationController!.forward(),
        iconColor: Colors.white,
        iconData: Icons.add,
        backGroundColor: primaryColor,
      ),
      extendBodyBehindAppBar: true,
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
                color: primaryColor,
                size: 35,
              ),
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (isLoggedIn) {
                toggleIsFav(product.id, userId!);
                showSnackBar("تم ", context);
                setState(() {});
              } else {
                showSnackBar("يجب تسجيل الدخول أولا", context);
              }
            },
            child: CircleAvatar(
              backgroundColor: litePrimary,
              child: currentUserId == null
                  ? const Icon(Icons.favorite_border, color: Colors.redAccent)
                  : StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .doc(product.id)
                          .collection('favorites')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data?.exists == false) {
                          return const Icon(Icons.favorite_border,
                              color: Colors.redAccent);
                        } else {
                          return const Icon(Icons.favorite,
                              color: Colors.redAccent);
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
      body: Consumer<CartData>(
        builder: (context, data, child) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => showImageBottom(),
                child: Container(
                  height: size.height / 2,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Swiper(
                    autoplay: true,
                    pagination: const SwiperPagination(
                      builder: SwiperPagination.dots,
                    ),
                    itemCount: product['images'].length,
                    itemBuilder: (context, index) => PhotoView(
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      maxScale: 100.0,
                      imageProvider: NetworkImage(
                        product['images'][index],
                        // fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product['title'],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ريال ${product['price']}',
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          'الصنف: ${product['sub_category']}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${product['quantity']} :متاح',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product['description'],
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      ':منتجات من المتجر',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(
                height: size.height / 3.9,
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: similarProducts,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            'لايوجد منتجات أخرى بعد',
                            style: TextStyle(
                              color: primaryColor,
                            ),
                          )
                        ],
                      );
                    }

                    return CarouselSlider.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index, i) {
                        var data = snapshot.data!.docs[index];

                        return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    product: data,
                                  ),
                                ),
                              ),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      Stack(children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            data['images'][0],
                                            width: 153,
                                            height: 153,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isLoggedIn) {
                                                toggleIsFav(data.id, userId!);
                                                showSnackBar("تم ", context);
                                                setState(() {});
                                              } else {
                                                showSnackBar(
                                                    "يجب تسجيل الدخول أولا",
                                                    context);
                                              }
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: litePrimary,
                                              child: currentUserId == null
                                                  ? const Icon(
                                                      Icons.favorite_border,
                                                      color: Colors.redAccent)
                                                  : StreamBuilder<
                                                      DocumentSnapshot>(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'products')
                                                          .doc(data.id)
                                                          .collection(
                                                              'favorites')
                                                          .doc(userId)
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData ||
                                                            snapshot.data
                                                                    ?.exists ==
                                                                false) {
                                                          return const Icon(
                                                              Icons
                                                                  .favorite_border,
                                                              color: Colors
                                                                  .redAccent);
                                                        } else {
                                                          return const Icon(
                                                              Icons.favorite,
                                                              color: Colors
                                                                  .redAccent);
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
                                              if (cartData.isItemOnCart(
                                                  data['prod_id'])) {
                                                removeFromCart(data['prod_id']);
                                              } else {
                                                if (!cartData.isOtherStor(
                                                        data['seller_id']) &&
                                                    cartData.cartItemCount >
                                                        0) {
                                                  // ignore: await_only_futures
                                                  deletCart =
                                                      await showClearCartOptions();
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
                                                      showSnackBar(
                                                          'حدث خطأ ما!',
                                                          context);

                                                      return;
                                                    }
                                                    if (mounted) {
                                                      showSnackBar(
                                                          "تم حذف المنتج و إستبداله ",
                                                          context);
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
                                              //  setState(() {});
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: litePrimary,
                                              child: Icon(
                                                cartData.isItemOnCart(
                                                        data['prod_id'])
                                                    ? Icons.shopping_cart
                                                    : Icons
                                                        .shopping_cart_outlined,
                                                // Icons.shopping_cart_outlined,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text('${data['price']}'),
                                          Text(
                                            data['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      },
                      options: CarouselOptions(
                        viewportFraction: 0.5,
                        aspectRatio: 1.5,
                        height: size.height / 3.0,
                        autoPlay: true,
                      ),
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
