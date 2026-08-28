import 'product_model.dart';

class CartItem {
  final String? id;
  final String sessionId;
  final String productId;
  final Product? product;
  final int quantity;
  final double unitPrice;

  CartItem({
    this.id,
    required this.sessionId,
    required this.productId,
    this.product,
    this.quantity = 1,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    return CartItem(
      id: map['id'],
      sessionId: map['session_id'] ?? '',
      productId: map['product_id'] ?? '',
      product: product,
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
    );
  }

  CartItem copyWith({
    String? id,
    String? sessionId,
    String? productId,
    Product? product,
    int? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
