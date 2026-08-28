import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class CartService {
  static const _uuid = Uuid();
  late String _sessionId;
  final List<CartItem> _items = [];

  CartService() {
    _sessionId = _uuid.v4();
  }

  String get sessionId => _sessionId;
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get igv => subtotal * 0.18;
  double get total => subtotal + igv;

  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((i) => i.productId == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        sessionId: _sessionId,
        productId: product.id!,
        product: product,
        quantity: quantity,
        unitPrice: product.unitPrice,
      ));
    }
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
  }

  void clear() {
    _items.clear();
    _sessionId = _uuid.v4();
  }

  bool containsProduct(String productId) {
    return _items.any((i) => i.productId == productId);
  }

  int getProductQuantity(String productId) {
    final item = _items.firstWhere(
      (i) => i.productId == productId,
      orElse: () => CartItem(
        sessionId: '',
        productId: '',
        unitPrice: 0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}
