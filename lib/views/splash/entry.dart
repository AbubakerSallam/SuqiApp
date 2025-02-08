import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:suqi/components/loading.dart';
import 'package:suqi/constants/colors.dart';
import 'package:suqi/views/splash/splash.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../components/no_internet.dart';
import '../auth/auth.dart';
import '../main/customer/customer_bottomNav.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry-screen';
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late StreamSubscription internetSubscribtion;
  bool isConnected = false;
  _startRun() async {
    bool ifr = await IsFirstRun.isFirstRun();
    var duration = const Duration(seconds: 2);
    // ignore: unnecessary_null_comparison
    if (ifr != null && !ifr) {
      Timer(duration, _navigateToSHome);
    } else {
      Timer(duration, _navigateToSplash);
    }
  }

  _navigateToSplash() {
    // Routing to Splash
    Navigator.of(context).pushNamedAndRemoveUntil(
      SplashScreen.routeName,
      (route) => false,
    );
  }

  _navigateToSHome() {
    // Routing to Home
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // home screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          CustomerBottomNav.routeName,
          // SellerBottomNav.routeName,
          (route) => false,
        );
      } else {
        // auth screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          Auth.routeName,
          (route) => false,
        );
      }
    });
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
    _checkConnection();
    _startRun();
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
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: primaryColor,
        child: !isConnected
            ? NoInternet(onpressed: _checkConnection)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo1.png'),
                  const SizedBox(height: 10),
                  const Loading(
                    color: Colors.white,
                    kSize: 40,
                  ),
                ],
              ),
      ),
    );
  }
}
