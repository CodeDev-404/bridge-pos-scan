import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onEdit;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.isLowStock
              ? AppTheme.warningColor.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            product.isLowStock ? Icons.warning_amber : Icons.inventory_2,
            color: product.isLowStock
                ? AppTheme.warningColor
                : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.barcode != null)
              Text(
                'Código: ${product.barcode}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            Row(
              children: [
                Text(
                  'Stock: ${product.stock} ${product.unit}',
                  style: TextStyle(
                    color: product.isLowStock
                        ? AppTheme.warningColor
                        : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: product.isLowStock
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (product.category != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category!,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${product.unitPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            if (onAddToCart != null)
              IconButton(
                onPressed: onAddToCart,
                icon: const Icon(
                  Icons.add_shopping_cart,
                  size: 20,
                  color: AppTheme.accentColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: onEdit,
      ),
    );
  }
}
