import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/sale_model.dart';
import '../../services/supabase_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cash';
  final _customerNameController = TextEditingController();
  final _customerDocController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerDocController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final sale = Sale(
        subtotal: cart.subtotal,
        igv: cart.igv,
        total: cart.total,
        paymentMethod: _paymentMethod,
        customerName: _customerNameController.text.isNotEmpty
            ? _customerNameController.text
            : null,
        customerDoc: _customerDocController.text.isNotEmpty
            ? _customerDocController.text
            : null,
      );

      final saleItems = cart.items
          .map((item) => SaleItem.fromCartItem(item))
          .toList();

      await _supabaseService.createSale(sale, saleItems);

      if (mounted) {
        cart.clear();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: 64,
        ),
        title: const Text('¡Venta registrada!'),
        content: const Text('La venta se ha guardado correctamente.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Return to cart
              Navigator.pop(context); // Return to home
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobrar'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary
                const Text(
                  'Resumen de la venta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ...cart.items.map((item) => ListTile(
                            title: Text(item.product?.name ?? 'Producto'),
                            subtitle: Text(
                              '${item.quantity} x S/ ${item.unitPrice.toStringAsFixed(2)}',
                            ),
                            trailing: Text(
                              'S/ ${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )),
                      const Divider(),
                      ListTile(
                        title: const Text('Subtotal'),
                        trailing: Text('S/ ${cart.subtotal.toStringAsFixed(2)}'),
                      ),
                      ListTile(
                        title: const Text('IGV (18%)'),
                        trailing: Text('S/ ${cart.igv.toStringAsFixed(2)}'),
                      ),
                      ListTile(
                        title: const Text(
                          'TOTAL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          'S/ ${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment method
                const Text(
                  'Método de pago',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'cash',
                      label: Text('Efectivo'),
                      icon: Icon(Icons.money),
                    ),
                    ButtonSegment(
                      value: 'card',
                      label: Text('Tarjeta'),
                      icon: Icon(Icons.credit_card),
                    ),
                    ButtonSegment(
                      value: 'transfer',
                      label: Text('Transferencia'),
                      icon: Icon(Icons.account_balance),
                    ),
                  ],
                  selected: {_paymentMethod},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() => _paymentMethod = selection.first);
                  },
                ),
                const SizedBox(height: 24),

                // Customer info (optional)
                const Text(
                  'Datos del cliente (opcional)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cliente',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerDocController,
                  decoration: const InputDecoration(
                    labelText: 'DNI / RUC',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Pay button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processPayment,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.payment),
                    label: Text(
                      _isProcessing
                          ? 'Procesando...'
                          : 'Cobrar S/ ${cart.total.toStringAsFixed(2)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
