class Product {
  final String? id;
  final String? barcode;
  final String name;
  final String? description;
  final double unitPrice;
  final double? costPrice;
  final int stock;
  final int minStock;
  final String? category;
  final String unit;
  final String? sunatCode;
  final String? imageUrl;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.barcode,
    required this.name,
    this.description,
    this.unitPrice = 0,
    this.costPrice,
    this.stock = 0,
    this.minStock = 5,
    this.category,
    this.unit = 'UN',
    this.sunatCode,
    this.imageUrl,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLowStock => stock <= minStock;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'stock': stock,
      'min_stock': minStock,
      'category': category,
      'unit': unit,
      'sunat_code': sunatCode,
      'image_url': imageUrl,
      'active': active,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'] ?? '',
      description: map['description'],
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
      costPrice: map['cost_price']?.toDouble(),
      stock: map['stock'] ?? 0,
      minStock: map['min_stock'] ?? 5,
      category: map['category'],
      unit: map['unit'] ?? 'UN',
      sunatCode: map['sunat_code'],
      imageUrl: map['image_url'],
      active: map['active'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    String? description,
    double? unitPrice,
    double? costPrice,
    int? stock,
    int? minStock,
    String? category,
    String? unit,
    String? sunatCode,
    String? imageUrl,
    bool? active,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      sunatCode: sunatCode ?? this.sunatCode,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
