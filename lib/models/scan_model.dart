class Scan {
  final String? id;
  final String scanType;
  final String? rawData;
  final String? decodedUrl;
  final String? productId;
  final String? saleId;
  final DateTime? createdAt;

  Scan({
    this.id,
    required this.scanType,
    this.rawData,
    this.decodedUrl,
    this.productId,
    this.saleId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'scan_type': scanType,
      'raw_data': rawData,
      'decoded_url': decodedUrl,
      'product_id': productId,
      'sale_id': saleId,
    };
  }

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      id: map['id'],
      scanType: map['scan_type'] ?? '',
      rawData: map['raw_data'],
      decodedUrl: map['decoded_url'],
      productId: map['product_id'],
      saleId: map['sale_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
