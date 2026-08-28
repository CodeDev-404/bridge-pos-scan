import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          // Supabase Connection
          const _SectionHeader(title: 'Conexión'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Supabase URL'),
            subtitle: Text(
              SupabaseConfig.supabaseUrl == 'YOUR_SUPABASE_URL'
                  ? 'No configurado'
                  : SupabaseConfig.supabaseUrl,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showEditDialog(
                context,
                'Supabase URL',
                SupabaseConfig.supabaseUrl,
                (value) {
                  // Would update config
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Supabase Anon Key'),
            subtitle: Text(
              SupabaseConfig.supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY'
                  ? 'No configurado'
                  : '${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showEditDialog(
                context,
                'Supabase Anon Key',
                SupabaseConfig.supabaseAnonKey,
                (value) {
                  // Would update config
                },
              );
            },
          ),
          const Divider(),

          // About
          const _SectionHeader(title: 'Acerca de'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Versión'),
            subtitle: Text('1.0.0+1'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Bridge+ POS Scan'),
            subtitle: Text('Lector QR/Código de barras para vwbta'),
          ),
          const ListTile(
            leading: Icon(Icons.business),
            title: Text('Sistema'),
            subtitle: Text('vwbta - Sistema de ventas MVP'),
          ),
          const Divider(),

          // Database setup
          const _SectionHeader(title: 'Base de datos'),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Estructura de tablas'),
            subtitle: const Text('Ver SQL de creación de tablas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSqlDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ingresa el valor',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showSqlDialog(BuildContext context) {
    const sql = '''
-- Bridge+ POS Scan - Estructura de tablas Supabase

-- Productos del inventario
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  barcode TEXT UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  unit_price DECIMAL(10,2),
  cost_price DECIMAL(10,2),
  stock INTEGER DEFAULT 0,
  min_stock INTEGER DEFAULT 5,
  category TEXT,
  unit TEXT DEFAULT 'UN',
  sunat_code TEXT,
  image_url TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Carrito de compras
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id TEXT NOT NULL,
  product_id UUID REFERENCES products(id),
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Ventas realizadas
CREATE TABLE sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number TEXT,
  subtotal DECIMAL(10,2),
  igv DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2),
  payment_method TEXT DEFAULT 'cash',
  customer_name TEXT,
  customer_doc TEXT,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Detalle de ventas
CREATE TABLE sale_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID REFERENCES sales(id),
  product_id UUID REFERENCES products(id),
  quantity INTEGER,
  unit_price DECIMAL(10,2),
  total DECIMAL(10,2)
);

-- Escaneos
CREATE TABLE scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_type TEXT NOT NULL,
  raw_data TEXT,
  decoded_url TEXT,
  product_id UUID REFERENCES products(id),
  sale_id UUID REFERENCES sales(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Facturas/Boletas
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id UUID REFERENCES scans(id),
  ruc TEXT,
  doc_type TEXT,
  series TEXT,
  number TEXT,
  issue_date DATE,
  total DECIMAL(10,2),
  currency TEXT DEFAULT 'PEN',
  customer_name TEXT,
  customer_doc TEXT,
  raw_xml TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Índices
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_sales_created ON sales(created_at DESC);
CREATE INDEX idx_scans_created ON scans(created_at DESC);
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Estructura SQL'),
        content: SingleChildScrollView(
          child: SelectableText(
            sql,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
