import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'dashboard_screens/account_balance.dart';
import 'dashboard_screens/manage_products.dart';
import 'dashboard_screens/orders.dart';
import 'dashboard_screens/statistics.dart';
import 'dashboard_screens/store_setup.dart';
import 'dashboard_screens/upload_product.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/seller-home';
  DashboardScreen({super.key});

  final List<dynamic> menuList = [
    {
      'title': 'إدارة المنتجات',
      'icon': Icons.storefront,
      'routeName': ManageProductsScreen.routeName,
    },
    {
      'title': 'تحميل منتجات',
      'icon': Icons.upload,
      'routeName': UploadProduct.routeName,
    },
    {
      'title': 'الطلبات',
      'icon': Icons.shopping_cart_checkout,
      'routeName': OrdersScreen.routeName,
    },
    {
      'title': 'الإحصائيات',
      'icon': Icons.insert_chart,
      'routeName': StatisticsScreen.routeName,
    },
    {
      'title': 'حسابي',
      'icon': Icons.monetization_on,
      'routeName': AccountBalanceScreen.routeName,
    },
    {
      'title': 'إدارة المتجر',
      'icon': Icons.store_sharp,
      'routeName': StoreSetupScreen.routeName,
    },
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(
        top: 48.0,
        right: 18,
        left: 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard,
                    color: primaryColor,
                  ),
                  Text(
                    'إدارة',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: size.height / 1.25,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 25,
                ),
                itemCount: menuList.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(menuList[index]['routeName']),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          menuList[index]['icon'],
                          size: 65,
                          color: primaryColor,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          menuList[index]['title'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
