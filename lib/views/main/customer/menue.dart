import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/kListTile.dart';
import '../../../constants/colors.dart';
import '../../../helpers/notification_helper.dart';
import '../../../providers/pay_money.dart';
import '../../../utilities/storage.dart';
import '../../auth/auth.dart';
import '../seller/seller_bottomNav.dart';
import '../../auth/store_login.dart';
import '../../../models/global.dart';

class MenueScreen extends StatefulWidget {
  const MenueScreen({super.key});

  @override
  State<MenueScreen> createState() => _MenueScreenState();
}

class _MenueScreenState extends State<MenueScreen> {
  bool _isLoggedIn = false;
  bool _hasStore = false;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  Future<void> checkUserLogin() async {
    if (currentUserId != null) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
        });
      }

      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('sellers')
          .doc(currentUserId)
          .get();

      if (mounted) {
        setState(() {
          _hasStore = userData.exists;
          if (_hasStore) {
            var storage = SLocalStorage();
            storage.saveData('storename', userData['fullname']);
            _isActive = userData['isactive'];
          }
        });
      }
    }
  }

  _settings() {}

  _navigateToStoreOrCreateIt() {
    if (!_isLoggedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Auth.routeName,
        (route) => false,
      );
    } else {
      if (_hasStore) {
        PushNotificationHelper.generateSellerToken();
        if (_isActive) {
          Navigator.of(context).pushNamed(SellerBottomNav.routeName);
        } else {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const PayMoney(),
                ),
              )
              .then(
                (value) => setState(
                  () {
                    //  showSnackBar('سيتم إبلاغك فور التحقق من الدفع', context);
                  },
                ),
              );
        }
      } else {
        // Navigate to add store screen
        Navigator.of(context).pushNamed(
          StoreAuth.routeName,
        );
      }
    }
  }

  _logout() async {
    if (currentUserId != null) {
      await FirebaseAuth.instance.signOut();
      FirebaseAuth.instance.authStateChanges();
      currentUserId = null;
      if (mounted) {
        Navigator.of(context).pushNamed(Auth.routeName);
      }
    }
  }

  showLogoutOptions() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Image.asset(
                'assets/images/profile.png',
                width: 35,
                color: primaryColor,
              ),
              const Text(
                'تسجيل خروج',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'متأكد من تسجيل الخروج?',
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
              onPressed: () => _logout(),
              child: const Text(
                'نعم',
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
              onPressed: () => Navigator.of(context).pop(),
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
    });
  }

  @override
  Widget build(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.only(top: 50, right: 10),
      child: SingleChildScrollView(
        child: Container(
          height: size.height / 1.25,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                width: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 24.0),
                child: Text(
                  textDirection: TextDirection.rtl,
                  'سوقي',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 29,
                      fontWeight: FontWeight.bold),
                ),
              ),
              KListTile(
                title: 'إعداداتي',
                icon: Icons.settings,
                onTapHandler: _settings,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: 'طلباتي',
                icon: Icons.edit_note,
                onTapHandler: _settings,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: 'عناويني',
                icon: Icons.key,
                onTapHandler: _settings,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: !_hasStore
                    ? 'افتح متجرك'
                    : !_isActive
                        ? 'تفعيل المتجر'
                        : 'إدارة المتجر',
                icon: Icons.store,
                onTapHandler: _navigateToStoreOrCreateIt,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: 'الدعم الفني',
                icon: Icons.store,
                onTapHandler: _settings,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: 'مشاركة التطبيق',
                icon: Icons.store,
                onTapHandler: _settings,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: 'سياسة الخصوصية',
                icon: Icons.store,
                onTapHandler: _settings,
                showSubtitle: false,
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
                child: Divider(thickness: 1),
              ),
              KListTile(
                title: 'تسجيل خروج',
                icon: Icons.logout_outlined,
                onTapHandler: showLogoutOptions,
                showSubtitle: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
