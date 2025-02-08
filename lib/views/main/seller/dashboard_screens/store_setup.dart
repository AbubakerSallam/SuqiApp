import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../components/kListTile.dart';
import '../../../../constants/colors.dart';
import '../../../../providers/pay_money.dart';
import '../../../../utilities/storage.dart';
import '../edit_profile.dart';

class StoreSetupScreen extends StatefulWidget {
  static const routeName = '/store_setup';
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  String storeName = SLocalStorage().readData('storename') ?? 'إعدادات المتجر';
  _editStore() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const EditProfile(),
          ),
        )
        .then(
          (value) => setState(
            () {},
          ),
        );
  }

  _goToPay() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const PayMoney(
              isUserMoney: false,
            ),
          ),
        )
        .then(
          (value) => setState(
            () {},
          ),
        );
  }

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      body: Padding(
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
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Text(
                    textDirection: TextDirection.rtl,
                    storeName,
                    style: const TextStyle(
                        color: primaryColor,
                        fontSize: 29,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                KListTile(
                  title: 'تعديل بروفايل المتجر',
                  icon: Icons.settings,
                  onTapHandler: _editStore,
                  showSubtitle: false,
                ),
                const Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Divider(thickness: 1),
                ),
                KListTile(
                  title: 'الترويج للمتجر أو منتج',
                  icon: Icons.edit_note,
                  onTapHandler: _goToPay,
                  showSubtitle: false,
                ),
                // const Padding(
                //   padding: EdgeInsets.all(1.0),
                //   child: Divider(thickness: 1),
                // ),
                // KListTile(
                //   title: 'عناويني',
                //   icon: Icons.key,
                //   onTapHandler: _settings,
                //   showSubtitle: false,
                // ),
                // const Padding(
                //   padding: EdgeInsets.all(1.0),
                //   child: Divider(thickness: 1),
                // ),
                // KListTile(
                //   title: 'الدعم الفني',
                //   icon: Icons.store,
                //   onTapHandler: _settings,
                //   showSubtitle: false,
                // ),
                // const Padding(
                //   padding: EdgeInsets.all(1.0),
                //   child: Divider(thickness: 1),
                // ),
                // KListTile(
                //   title: 'مشاركة التطبيق',
                //   icon: Icons.store,
                //   onTapHandler: _settings,
                //   showSubtitle: false,
                // ),
                // const Padding(
                //   padding: EdgeInsets.all(1.0),
                //   child: Divider(thickness: 1),
                // ),
                // KListTile(
                //   title: 'سياسة الخصوصية',
                //   icon: Icons.store,
                //   onTapHandler: _settings,
                //   showSubtitle: false,
                // ),
                // const Padding(
                //   padding: EdgeInsets.all(1.0),
                //   child: Divider(thickness: 1),
                // ),
                // KListTile(
                //   title: 'تسجيل خروج',
                //   icon: Icons.logout_outlined,
                //   onTapHandler: _settings,
                //   showSubtitle: false,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
