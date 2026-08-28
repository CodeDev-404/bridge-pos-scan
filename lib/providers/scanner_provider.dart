import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';
import '../services/scanner_service.dart';
import '../services/sunat_service.dart';

class ScannerProvider extends ChangeNotifier {
  final ScannerService _scannerService = ScannerService();
  final SunatService _sunatService = SunatService();

  ScanMode get currentMode => _scannerService.currentMode;
  Product? _lastScannedProduct;
  Invoice? _lastScannedInvoice;
  String? _lastRawData;
  bool _isProcessing = false;

  Product? get lastScannedProduct => _lastScannedProduct;
  Invoice? get lastScannedInvoice => _lastScannedInvoice;
  String? get lastRawData => _lastRawData;
  bool get isProcessing => _isProcessing;

  void setMode(ScanMode mode) {
    _scannerService.setMode(mode);
    notifyListeners();
  }

  void toggleMode() {
    if (_scannerService.currentMode == ScanMode.invoice) {
      _scannerService.setMode(ScanMode.product);
    } else {
      _scannerService.setMode(ScanMode.invoice);
    }
    notifyListeners();
  }

  void processScanResult(String rawData, dynamic barcode) {
    _isProcessing = true;
    _lastRawData = rawData;
    notifyListeners();

    final detectedMode = _scannerService.detectMode(rawData, barcode?.format);

    if (detectedMode == ScanMode.invoice) {
      _lastScannedInvoice = _sunatService.parseInvoiceQr(rawData);
      _lastScannedProduct = null;
    } else {
      // For product barcodes, the lookup happens in the screen
      _lastScannedProduct = null;
      _lastScannedInvoice = null;
    }

    _isProcessing = false;
    notifyListeners();
  }

  void setScannedProduct(Product product) {
    _lastScannedProduct = product;
    notifyListeners();
  }

  void clearLastScan() {
    _lastScannedProduct = null;
    _lastScannedInvoice = null;
    _lastRawData = null;
    notifyListeners();
  }
}
