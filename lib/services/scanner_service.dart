import 'package:mobile_scanner/mobile_scanner.dart';

enum ScanMode {
  invoice,
  product,
}

class ScannerService {
  ScanMode _currentMode = ScanMode.product;

  ScanMode get currentMode => _currentMode;

  void setMode(ScanMode mode) {
    _currentMode = mode;
  }

  /// Determine if a barcode result is an invoice QR
  bool isInvoiceQr(String rawData) {
    if (rawData.startsWith('http') && rawData.contains('sunat')) {
      return true;
    }
    // Pattern for invoice series: F001-00000001, B001-00000001
    final invoicePattern = RegExp(r'^[FB]\d{3}-\d{6,8}$');
    if (invoicePattern.hasMatch(rawData)) {
      return true;
    }
    // Pipe-separated invoice data
    if (rawData.contains('|') && rawData.split('|').length >= 5) {
      return true;
    }
    return false;
  }

  /// Determine if a barcode is a product barcode (EAN, UPC, etc.)
  bool isProductBarcode(String rawData, BarcodeFormat? format) {
    if (format == null) return false;

    switch (format) {
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
      case BarcodeFormat.code128:
      case BarcodeFormat.code39:
      case BarcodeFormat.code93:
      case BarcodeFormat.itf14:
        return true;
      default:
        return false;
    }
  }

  /// Get the appropriate scan mode based on barcode data
  ScanMode detectMode(String rawData, BarcodeFormat? format) {
    if (isInvoiceQr(rawData)) {
      return ScanMode.invoice;
    }
    return ScanMode.product;
  }
}
