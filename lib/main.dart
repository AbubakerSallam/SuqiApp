// ignore_for_file: depend_on_referenced_packages, unused_local_variable

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:suqi/constants/colors.dart';
import 'package:suqi/providers/cart.dart';
import 'firebase_options.dart';
import 'package:suqi/views/splash/entry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartData(),
        ),
      ],
      child: const SuqiApp(),
    ),
  );
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SuqiApp extends StatefulWidget {
  const SuqiApp({super.key});

  @override
  State<SuqiApp> createState() => _SuqiAppState();
}

class _SuqiAppState extends State<SuqiApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'سوقي',
      theme: ThemeData(
        fontFamily: 'Mada',
        primaryColor: primaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: const EntryScreen(),
      routes: routes,
    );
  }
}
