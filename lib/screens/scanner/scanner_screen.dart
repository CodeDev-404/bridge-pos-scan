import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/scanner_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../services/scanner_service.dart';
import '../../services/sunat_service.dart';
import '../../widgets/scanner_overlay.dart';
import '../cart/cart_screen.dart';
import '../products/product_form_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  final SunatService _sunatService = SunatService();
  Barcode? _lastBarcode;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _isInitialized = true;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue == null) continue;
      if (_lastBarcode?.rawValue == barcode.rawValue) return;

      _lastBarcode = barcode;
      _isProcessing = true;

      _handleScanResult(barcode.rawValue!, barcode);
      break;
    }
  }

  Future<void> _handleScanResult(String rawData, Barcode barcode) async {
    final productsProvider = context.read<ProductsProvider>();

    // Check if it's an invoice QR
    if (_sunatService.isInvoiceQr(rawData)) {
      final invoice = _sunatService.parseInvoiceQr(rawData);
      if (invoice != null) {
        _showInvoiceDialog(invoice, rawData);
      } else {
        _showSnackBar('No se pudo parsear el código de factura', isError: true);
      }
      _isProcessing = false;
      return;
    }

    // It's a product barcode - search in database
    final product = await productsProvider.getProductByBarcode(rawData);

    if (product != null) {
      _showProductFoundDialog(product);
    } else {
      _showProductNotFoundDialog(rawData);
    }

    _isProcessing = false;
  }

  void _showProductFoundDialog(Product product) {
    final cartProvider = context.read<CartProvider>();
    final inCart = cartProvider.containsProduct(product.id!);
    final qtyInCart = cartProvider.getProductQuantity(product.id!);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          inCart ? Icons.shopping_cart : Icons.inventory_2,
          color: inCart ? AppTheme.accentColor : AppTheme.primaryColor,
          size: 48,
        ),
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.barcode != null)
              Text('Código: ${product.barcode}',
                  style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'S/ ${product.unitPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Stock: ${product.stock} ${product.unit}'),
            if (inCart) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text('$qtyInCart en carrito'),
                backgroundColor: AppTheme.accentColor.withOpacity(0.1),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              cartProvider.addItem(product);
              Navigator.pop(ctx);
              _showSnackBar('${product.name} agregado al carrito');
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Agregar al carrito'),
          ),
        ],
      ),
    );
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.help_outline,
          color: AppTheme.warningColor,
          size: 48,
        ),
        title: const Text('Producto no encontrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: $barcode',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            const Text('¿Deseas crear un nuevo producto con este código?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(initialBarcode: barcode),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear producto'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(dynamic invoice, String rawData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.receipt_long,
          color: AppTheme.primaryColor,
          size: 48,
        ),
        title: Text('${invoice.docTypeLabel} ${invoice.fullNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RUC: ${invoice.ruc}',
                style: TextStyle(color: Colors.grey[600])),
            if (invoice.issueDate != null)
              Text('Fecha: ${invoice.issueDate}',
                  style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'S/ ${invoice.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los productos de esta factura se pueden importar a tu inventario.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Función de importación próximamente');
            },
            icon: const Icon(Icons.download),
            label: const Text('Importar productos'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear'),
        actions: [
          // Mode toggle
          Consumer<ScannerProvider>(
            builder: (context, scanner, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: GestureDetector(
                    onTap: scanner.toggleMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scanner.currentMode == ScanMode.invoice
                            ? Colors.orange.withOpacity(0.2)
                            : AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scanner.currentMode == ScanMode.invoice
                              ? Colors.orange
                              : AppTheme.accentColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            scanner.currentMode == ScanMode.invoice
                                ? Icons.receipt_long
                                : Icons.qr_code_scanner,
                            size: 16,
                            color: scanner.currentMode == ScanMode.invoice
                                ? Colors.orange
                                : AppTheme.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            scanner.currentMode == ScanMode.invoice
                                ? 'Factura'
                                : 'Producto',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: scanner.currentMode == ScanMode.invoice
                                  ? Colors.orange
                                  : AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Flash toggle
          IconButton(
            onPressed: () => _cameraController?.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: _cameraController ?? MobileScannerController(),
              builder: (context, state, child) {
                final torchState = state as TorchState?;
                return Icon(
                  torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: torchState == TorchState.on
                      ? Colors.yellow
                      : Colors.white,
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isInitialized && _cameraController != null)
            MobileScanner(
              controller: _cameraController!,
              onDetect: _onDetect,
            ),
          // Custom overlay
          const ScannerOverlay(),
          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<ScannerProvider>(
                      builder: (context, scanner, _) {
                        return Text(
                          scanner.currentMode == ScanMode.invoice
                              ? 'Apunte al QR de la factura o boleta'
                              : 'Apunte al código de barras del producto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          label: Consumer<CartProvider>(
                            builder: (context, cart, _) {
                              return Text(
                                'Carrito (${cart.itemCount})',
                                style: const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
