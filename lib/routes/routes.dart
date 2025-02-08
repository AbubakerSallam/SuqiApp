import 'package:suqi/views/splash/splash.dart';
import '../utilities/natifications.dart';
import '../views/auth/auth.dart';
import '../views/home.dart';
import '../views/main/customer/customer_bottomNav.dart';
import '../views/main/customer/favorites.dart';
import '../views/main/customer/order.dart';
import '../views/main/seller/dashboard_screens/account_balance.dart';
import '../views/main/seller/dashboard_screens/manage_products.dart';
import '../views/main/seller/dashboard_screens/orders.dart';
import '../views/main/seller/dashboard_screens/statistics.dart';
import '../views/main/seller/dashboard_screens/store_setup.dart';
import '../views/main/seller/dashboard_screens/upload_product.dart';
import '../views/main/seller/seller_bottomNav.dart';
import '../views/auth/store_login.dart';
import '../utilities/google_maps.dart';

var routes = {
  Auth.routeName: (context) => const Auth(),
  StoreAuth.routeName: (context) => const StoreAuth(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  CustomerBottomNav.routeName: (context) => const CustomerBottomNav(
        currentPageIndex: 3,
      ),
  ManageProductsScreen.routeName: (context) => const ManageProductsScreen(),
  UploadProduct.routeName: (context) => const UploadProduct(),
  OrdersScreen.routeName: (context) => const OrdersScreen(),
  StoreSetupScreen.routeName: (context) => const StoreSetupScreen(),
  StatisticsScreen.routeName: (context) => const StatisticsScreen(),
  AccountBalanceScreen.routeName: (context) => const AccountBalanceScreen(),
  NatificationsScreen.routeName: (context) => const NatificationsScreen(),
  CustomerOrderScreen.routeName: (context) => const CustomerOrderScreen(),
  SellerBottomNav.routeName: (context) => const SellerBottomNav(),
  FavoriteScreen.routeName: (context) => const FavoriteScreen(),
  MapScreen.routeName: (context) => const MapScreen(),

  // MapScreen.routeName: (context) => const MapScreen(),
};
