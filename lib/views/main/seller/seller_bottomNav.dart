// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/constants/colors.dart';
import 'dashboard.dart';

import '../store/store.dart';

class SellerBottomNav extends StatefulWidget {
  static const routeName = '/seller-home';

  const SellerBottomNav({super.key});

  @override
  State<SellerBottomNav> createState() => _SellerBottomNavState();
}

class _SellerBottomNavState extends State<SellerBottomNav> {
  var currentPageIndex = 0;
  final _pages = [
    DashboardScreen(),
    const StoreScreen(),
  ];

  selectPage(var index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
    
      backgroundColor: Colors.grey.shade200,
      body: _pages[currentPageIndex],
    );
  }
}
