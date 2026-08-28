import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartService get cart => _cartService;
  List<CartItem> get items => _cartService.items;
  int get itemCount => _cartService.itemCount;
  double get subtotal => _cartService.subtotal;
  double get igv => _cartService.igv;
  double get total => _cartService.total;

  void addItem(Product product, {int quantity = 1}) {
    _cartService.addItem(product, quantity: quantity);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    _cartService.updateQuantity(productId, quantity);
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartService.removeItem(productId);
    notifyListeners();
  }

  void clear() {
    _cartService.clear();
    notifyListeners();
  }

  bool containsProduct(String productId) {
    return _cartService.containsProduct(productId);
  }

  int getProductQuantity(String productId) {
    return _cartService.getProductQuantity(productId);
  }
}
