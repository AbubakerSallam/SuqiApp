import 'cart.dart';
class Order {
  final String id;
  final String userId;
  final String storeId;
  final double totalPrice;
  final List<CartItem> items;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.totalPrice,
    required this.items,
    required this.orderDate,
    required this.status,
  });
}
