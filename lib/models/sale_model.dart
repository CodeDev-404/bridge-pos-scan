import 'cart_item_model.dart';

class Sale {
  final String? id;
  final String? invoiceNumber;
  final double subtotal;
  final double igv;
  final double total;
  final String paymentMethod;
  final String? customerName;
  final String? customerDoc;
  final String status;
  final List<SaleItem>? items;
  final DateTime? createdAt;

  Sale({
    this.id,
    this.invoiceNumber,
    this.subtotal = 0,
    this.igv = 0,
    this.total = 0,
    this.paymentMethod = 'cash',
    this.customerName,
    this.customerDoc,
    this.status = 'completed',
    this.items,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_number': invoiceNumber,
      'subtotal': subtotal,
      'igv': igv,
      'total': total,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_doc': customerDoc,
      'status': status,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      igv: (map['igv'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? 'cash',
      customerName: map['customer_name'],
      customerDoc: map['customer_doc'],
      status: map['status'] ?? 'completed',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}

class SaleItem {
  final String? id;
  final String? saleId;
  final String? productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double total;

  SaleItem({
    this.id,
    this.saleId,
    this.productId,
    this.productName,
    this.quantity = 1,
    this.unitPrice = 0,
    this.total = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }

  factory SaleItem.fromCartItem(CartItem cartItem) {
    return SaleItem(
      productId: cartItem.productId,
      productName: cartItem.product?.name,
      quantity: cartItem.quantity,
      unitPrice: cartItem.unitPrice,
      total: cartItem.total,
    );
  }
}
