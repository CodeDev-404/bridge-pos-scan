import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/scan_model.dart';
import '../models/invoice_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ==================== PRODUCTS ====================

  Future<List<Product>> getProducts({String? search, bool activeOnly = true}) async {
    var query = _client.from(SupabaseConfig.productsTable).select();
    if (activeOnly) {
      query = query.eq('active', true);
    }
    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,barcode.ilike.%$search%');
    }
    final data = await query.order('name');
    return (data as List).map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final data = await _client
        .from(SupabaseConfig.productsTable)
        .select()
        .eq('barcode', barcode)
        .eq('active', true)
        .maybeSingle();
    return data != null ? Product.fromMap(data) : null;
  }

  Future<Product> createProduct(Product product) async {
    final data = await _client
        .from(SupabaseConfig.productsTable)
        .insert(product.toMap())
        .select()
        .single();
    return Product.fromMap(data);
  }

  Future<Product> updateProduct(Product product) async {
    final data = await _client
        .from(SupabaseConfig.productsTable)
        .update(product.toMap())
        .eq('id', product.id!)
        .select()
        .single();
    return Product.fromMap(data);
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _client
        .from(SupabaseConfig.productsTable)
        .update({'stock': newStock, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', productId);
  }

  Future<List<Product>> getLowStockProducts() async {
    final data = await _client
        .from(SupabaseConfig.productsTable)
        .select()
        .eq('active', true)
        .lte('stock', _client.rpc('min_stock'))
        .order('stock');
    return (data as List).map((e) => Product.fromMap(e)).toList();
  }

  // ==================== SALES ====================

  Future<Sale> createSale(Sale sale, List<SaleItem> items) async {
    final saleData = await _client
        .from(SupabaseConfig.salesTable)
        .insert(sale.toMap())
        .select()
        .single();

    final saleId = saleData['id'] as String;

    final saleItems = items.map((item) {
      final itemMap = item.toMap();
      itemMap['sale_id'] = saleId;
      return itemMap;
    }).toList();

    await _client.from(SupabaseConfig.saleItemsTable).insert(saleItems);

    // Update stock for each product
    for (final item in items) {
      if (item.productId != null) {
        final product = await _client
            .from(SupabaseConfig.productsTable)
            .select('stock')
            .eq('id', item.productId!)
            .single();
        final currentStock = product['stock'] as int;
        await updateStock(item.productId!, currentStock - item.quantity);
      }
    }

    return Sale.fromMap(saleData);
  }

  Future<List<Sale>> getSales({int limit = 50}) async {
    final data = await _client
        .from(SupabaseConfig.salesTable)
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Sale.fromMap(e)).toList();
  }

  // ==================== SCANS ====================

  Future<Scan> saveScan(Scan scan) async {
    final data = await _client
        .from(SupabaseConfig.scansTable)
        .insert(scan.toMap())
        .select()
        .single();
    return Scan.fromMap(data);
  }

  Future<List<Scan>> getScans({String? type, int limit = 50}) async {
    var query = _client.from(SupabaseConfig.scansTable).select();
    if (type != null) {
      query = query.eq('scan_type', type);
    }
    final data = await query.order('created_at', ascending: false).limit(limit);
    return (data as List).map((e) => Scan.fromMap(e)).toList();
  }

  // ==================== INVOICES ====================

  Future<Invoice> saveInvoice(Invoice invoice) async {
    final data = await _client
        .from(SupabaseConfig.invoicesTable)
        .insert(invoice.toMap())
        .select()
        .single();
    return Invoice.fromMap(data);
  }

  Future<List<Invoice>> getInvoices({int limit = 50}) async {
    final data = await _client
        .from(SupabaseConfig.invoicesTable)
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Invoice.fromMap(e)).toList();
  }

  // ==================== STATS ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final salesToday = await _client
        .from(SupabaseConfig.salesTable)
        .select('total')
        .gte('created_at', startOfDay.toIso8601String())
        .eq('status', 'completed');

    final totalSales = (salesToday as List)
        .fold<double>(0, (sum, e) => sum + (e['total'] ?? 0).toDouble());

    final productCount = await _client
        .from(SupabaseConfig.productsTable)
        .select()
        .eq('active', true)
        .count();

    final scanCount = await _client
        .from(SupabaseConfig.scansTable)
        .select()
        .gte('created_at', startOfDay.toIso8601String())
        .count();

    return {
      'sales_today': totalSales,
      'sales_count': salesToday.length,
      'product_count': productCount.count,
      'scans_today': scanCount.count,
    };
  }
}
