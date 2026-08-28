import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

class ProductsProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  Future<void> loadProducts({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _supabaseService.getProducts(search: search);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return await _supabaseService.getProductByBarcode(barcode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Product?> createProduct(Product product) async {
    try {
      final newProduct = await _supabaseService.createProduct(product);
      _products.insert(0, newProduct);
      notifyListeners();
      return newProduct;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Product?> updateProduct(Product product) async {
    try {
      final updated = await _supabaseService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == updated.id);
      if (index >= 0) {
        _products[index] = updated;
        notifyListeners();
      }
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
