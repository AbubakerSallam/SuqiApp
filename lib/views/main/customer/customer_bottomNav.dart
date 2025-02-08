// ignore_for_file: file_names, deprecated_member_use, unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:suqi/components/no_internet.dart';
import 'package:suqi/models/global.dart';
import '../../../constants/colors.dart';
import '../../../helpers/notification_helper.dart';
import '../../../providers/cart.dart';
import '../../../utilities/showMessage.dart';
import '../../auth/auth.dart';
import '../../home.dart';
import 'cart.dart';
import 'favorites.dart';
import 'profile.dart';
import 'menue.dart';
import '../store/store.dart';
import 'package:badges/badges.dart' as bdg;
import 'package:location/location.dart';

class CustomerBottomNav extends StatefulWidget {
  static const routeName = '/customer-home';

  const CustomerBottomNav({super.key, required int currentPageIndex});

  @override
  State<CustomerBottomNav> createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav> {
  Location location = Location();
  DateTime timeBackPressed = DateTime.now();
  late StreamSubscription internetSubscribtion;
  var currentPageIndex = 3;
  bool isLoggedIn = false;
  bool isConnected = true;
  final _pages = const [
    MenueScreen(),
    FavoriteScreen(),
    StoreScreen(),
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  Future<void> checkUserLogin() async {
    if (currentUserId != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  showLoginOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'تسجيل دخول !',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'يجب عليك تسجيل الدخول اولا',
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                Auth.routeName,
                (route) => false,
              );
            },
            child: const Text(
              'تسجيل الدخول',
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
              Navigator.of(context).pop();
            },
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkConnection() {
    internetSubscribtion =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(() => isConnected = hasInternet);
    });
  }

  @override
  void initState() {
    super.initState();
    internetSubscribtion =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(() => isConnected = hasInternet);
    });
    _checkConnection();
    checkUserLogin();
    if (isConnected) {
      PushNotificationHelper.initialize(context);

      if (isLoggedIn) {
        PushNotificationHelper.generateDeviceToken();
      }
    }
    _checkLocation();
  }

  _checkLocation() async {
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        //  return Future.error('Service not enabled');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    internetSubscribtion.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartData>(context, listen: false);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primaryColor,
        activeColor: Colors.white,
        initialActiveIndex: currentPageIndex,
        style: TabStyle.reactCircle,
        items: [
          const TabItem(
            icon: Icons.menu_open,
          ),
          const TabItem(
            icon: Icons.favorite_border,
          ),
          const TabItem(
            icon: Icons.storefront,
          ),
          const TabItem(
            icon: Icons.house_siding,
          ),
          TabItem(
            icon: Consumer<CartData>(
              builder: (context, data, child) => bdg.Badge(
                badgeContent: Text(
                  cartData.cartItemCount.toString(),
                  style: const TextStyle(
                    color: primaryColor,
                  ),
                ),
                showBadge: cartData.cartItems.isNotEmpty ? true : false,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: currentPageIndex == 4 ? 40 : 25,
                  color: currentPageIndex == 4 ? primaryColor : Colors.white70,
                ),
              ),
            ),
          ),
          const TabItem(
            icon: Icons.person_outline,
          )
        ],
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
          // }
        },
      ),
      backgroundColor: Colors.grey.shade200,
      body: WillPopScope(
          onWillPop: () async {
            final difference = DateTime.now().difference(timeBackPressed);
            final isWarning = difference >= const Duration(seconds: 2);
            timeBackPressed = DateTime.now();
            if (isWarning) {
              showSnackBar('إضغط مرة أخرى  للخروج', context);
              // const SnackBar(
              //   content: Text(
              //     style: TextStyle(backgroundColor: Colors.red),
              //     'إضغط مرة أخرى  للخروج',
              //     textDirection: TextDirection.ltr,
              //   ),
              // duration: Duration(seconds: 2),
              // );
              return false;
            } else {
              return true;
            }
          },
          child: !isConnected
              ? NoInternet(onpressed: _checkConnection)
              : _pages[currentPageIndex]),
    );
  }
}
