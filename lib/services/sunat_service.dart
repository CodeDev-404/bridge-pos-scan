import '../models/invoice_model.dart';

class SunatService {
  // Parse QR data from Peruvian electronic invoices
  // The QR typically contains a URL like:
  // https://www.sunat.gob.pe/verificaCpe/verificar?expiration=...&ruc=...&cod=...

  static const String _sunatVerifyUrl = 'https://www.sunat.gob.pe/verificaCpe/verificar';

  /// Parse raw QR data from invoice
  Invoice? parseInvoiceQr(String rawData) {
    try {
      // Try to parse as URL first
      if (rawData.startsWith('http')) {
        return _parseFromUrl(rawData);
      }

      // Try to parse as structured data
      return _parseFromStructuredData(rawData);
    } catch (e) {
      return null;
    }
  }

  Invoice? _parseFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;

      if (params.containsKey('ruc') || params.containsKey('cod')) {
        return Invoice(
          ruc: params['ruc'] ?? '',
          docType: _extractDocType(params['cod'] ?? ''),
          series: _extractSeries(params['cod'] ?? ''),
          number: _extractNumber(params['cod'] ?? ''),
          total: double.tryParse(params['mto'] ?? '0') ?? 0,
        );
      }

      // Alternative URL format
      if (uri.pathSegments.contains('verificar')) {
        return Invoice(
          ruc: params['ruc'] ?? '',
          docType: _extractDocTypeFromCode(params['tipoDoc'] ?? ''),
          series: params['serie'] ?? '',
          number: params['numero'] ?? '',
          total: double.tryParse(params['total'] ?? '0') ?? 0,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Invoice? _parseFromStructuredData(String data) {
    try {
      // Some QR codes contain pipe-separated data
      // Format: ruc|tipoDoc|serie|numero|fecha|total|rucEmisor
      final parts = data.split('|');
      if (parts.length >= 6) {
        return Invoice(
          ruc: parts[0],
          docType: parts[1],
          series: parts[2],
          number: parts[3],
          issueDate: DateTime.tryParse(parts[4]),
          total: double.tryParse(parts[5]) ?? 0,
        );
      }

      // Try JSON format
      if (data.startsWith('{')) {
        // Would parse JSON here
        return null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String _extractDocType(String code) {
    if (code.length >= 2) {
      final prefix = code.substring(0, 1);
      switch (prefix) {
        case 'F':
          return '01'; // Factura
        case 'B':
          return '03'; // Boleta
        case 'N':
          return code.length > 1 && code[1] == 'C' ? '07' : '08';
        default:
          return '01';
      }
    }
    return '01';
  }

  String _extractDocTypeFromCode(String code) {
    switch (code) {
      case '01':
        return '01';
      case '03':
        return '03';
      case '07':
        return '07';
      case '08':
        return '08';
      default:
        return '01';
    }
  }

  String _extractSeries(String code) {
    // Extract series from code like "F001-00000001"
    if (code.contains('-')) {
      return code.split('-').first;
    }
    if (code.length > 4) {
      return code.substring(0, 4);
    }
    return code;
  }

  String _extractNumber(String code) {
    // Extract number from code like "F001-00000001"
    if (code.contains('-')) {
      return code.split('-').last;
    }
    if (code.length > 4) {
      return code.substring(4);
    }
    return '';
  }

  /// Check if a scanned value is likely an invoice QR
  bool isInvoiceQr(String rawData) {
    if (rawData.startsWith('http') && rawData.contains('sunat')) {
      return true;
    }
    // Check for structured invoice data patterns
    if (rawData.contains('|') && rawData.split('|').length >= 5) {
      return true;
    }
    // Check for series-number pattern (F001-000001, B001-000001)
    final seriesPattern = RegExp(r'^[FB]\d{3}-\d{6,8}$');
    if (seriesPattern.hasMatch(rawData)) {
      return true;
    }
    return false;
  }

  /// Get the SUNAT verification URL for display
  String getVerificationUrl(Invoice invoice) {
    return '$_sunatVerifyUrl?ruc=${invoice.ruc}&cod=${invoice.fullNumber}';
  }
}
