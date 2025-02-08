import 'package:flutter/material.dart';
import '../models/cart.dart';

class CartData extends ChangeNotifier {
  var totalPrice = 0.0;
  void clearCart() async {
    _cartItems.clear();
    notifyListeners();
  }

  bool isItemOnCart(String prodId) {
    return _cartItems.any((item) => item.prodId == prodId);
  }

  bool isOtherStor(String sellerId) {
    return _cartItems.any((item) => item.sellerId == sellerId);
  }

  void incrementProductQuantity(String id) {
    var cartItem = _cartItems.firstWhere(
      (item) => item.id == id,
    );
    cartItem.incrementQuantity();
    notifyListeners();
  }

  void decrementProductQuantity(String id) {
    var cartItem = _cartItems.firstWhere(
      (item) => item.id == id,
    );
    cartItem.decrementQuantity();
    if (cartItem.quantity < 1) {
      _cartItems.remove(cartItem);
    }
    notifyListeners();
  }

  void addToCart(CartItem cart) {
    CartItem item = CartItem(
      id: DateTime.now().toString(),
      docId: cart.docId,
      prodId: cart.prodId,
      sellerId: cart.sellerId,
      prodName: cart.prodName,
      prodPrice: cart.prodPrice,
      prodImgUrl: cart.prodImgUrl,
      totalPrice: cart.totalPrice,
    );

    _cartItems.add(item);
    // _saveCartItems(); // Save to SharedPreferences
    notifyListeners();
  }

  void removeFromCart(String prodId) {
    var cartItem = _cartItems.firstWhere(
      (item) => item.prodId == prodId,
    );
    _cartItems.remove(cartItem);
    // _saveCartItems(); // Save to SharedPreferences
    notifyListeners();
  }

  get cartItemCount {
    return _cartItems.length;
  }

String get sellerId {
  return _cartItems.isNotEmpty ? _cartItems[0].sellerId : ''; // Assuming _cartItems is a list of CartItem objects
}

  get cartTotalPrice {
    totalPrice = 0.0;
    for (var item in _cartItems) {
      totalPrice += item.totalPrice;
    }
    return totalPrice;
  }

  List<CartItem> get cartItems {
    return [..._cartItems];
  }

   final _cartItems = [];
}
