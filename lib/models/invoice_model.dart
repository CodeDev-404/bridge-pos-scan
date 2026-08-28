class Invoice {
  final String? id;
  final String? scanId;
  final String ruc;
  final String docType;
  final String series;
  final String number;
  final DateTime? issueDate;
  final double total;
  final String currency;
  final String? customerName;
  final String? customerDoc;
  final String? rawXml;
  final List<InvoiceProduct>? products;
  final DateTime? createdAt;

  Invoice({
    this.id,
    this.scanId,
    required this.ruc,
    required this.docType,
    required this.series,
    required this.number,
    this.issueDate,
    this.total = 0,
    this.currency = 'PEN',
    this.customerName,
    this.customerDoc,
    this.rawXml,
    this.products,
    this.createdAt,
  });

  String get docTypeLabel {
    switch (docType) {
      case '01':
        return 'Factura';
      case '03':
        return 'Boleta';
      case '07':
        return 'Nota de Crédito';
      case '08':
        return 'Nota de Débito';
      default:
        return 'Comprobante';
    }
  }

  String get fullNumber => '$series-$number';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'scan_id': scanId,
      'ruc': ruc,
      'doc_type': docType,
      'series': series,
      'number': number,
      'issue_date': issueDate?.toIso8601String().split('T').first,
      'total': total,
      'currency': currency,
      'customer_name': customerName,
      'customer_doc': customerDoc,
      'raw_xml': rawXml,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      scanId: map['scan_id'],
      ruc: map['ruc'] ?? '',
      docType: map['doc_type'] ?? '',
      series: map['series'] ?? '',
      number: map['number'] ?? '',
      issueDate: map['issue_date'] != null ? DateTime.parse(map['issue_date']) : null,
      total: (map['total'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'PEN',
      customerName: map['customer_name'],
      customerDoc: map['customer_doc'],
      rawXml: map['raw_xml'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}

class InvoiceProduct {
  final int lineNumber;
  final String? code;
  final String? sunatCode;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double total;

  InvoiceProduct({
    this.lineNumber = 0,
    this.code,
    this.sunatCode,
    required this.description,
    this.quantity = 1,
    this.unit = 'UN',
    this.unitPrice = 0,
    this.total = 0,
  });
}
