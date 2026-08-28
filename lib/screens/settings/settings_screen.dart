import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);

    try {
      // Try a simple query to verify connection
      await Supabase.instance.client
          .from(SupabaseConfig.productsTable)
          .select('id')
          .limit(1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión exitosa ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _saveConfig(String url, String key) async {
    await SupabaseConfig.updateConfig(url, key);

    // Reinitialize Supabase client
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: key,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada y reconectada'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reconectar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetConfig() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer configuración'),
        content: const Text(
          'Esto borrará la URL y Key guardadas. La app volverá a usar los valores por defecto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseConfig.resetToDefault();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración restablecida')),
        );
        setState(() {});
      }
    }
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required Function(String) onSave,
    bool obscureText = false,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: const InputDecoration(
            hintText: 'Ingresa el valor',
          ),
          maxLines: obscureText ? 1 : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final url = SupabaseConfig.supabaseUrl;
    final key = SupabaseConfig.supabaseAnonKey;
    final hasCustomConfig = url != 'YOUR_SUPABASE_URL';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          // Supabase Connection
          const _SectionHeader(title: 'Conexión Supabase'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Supabase URL'),
            subtitle: Text(
              hasCustomConfig ? url : 'No configurado (usando default)',
              style: TextStyle(
                color: hasCustomConfig ? null : Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditDialog(
              context: context,
              title: 'Supabase URL',
              currentValue: url,
              onSave: (value) => _saveConfig(value, key),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Publishable Key (Anon Key)'),
            subtitle: Text(
              hasCustomConfig
                  ? '${key.substring(0, 20)}...'
                  : 'No configurado (usando default)',
              style: TextStyle(
                color: hasCustomConfig ? null : Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditDialog(
              context: context,
              title: 'Publishable Key',
              currentValue: key,
              obscureText: true,
              onSave: (value) => _saveConfig(url, value),
            ),
          ),
          ListTile(
            leading: Icon(_isTesting ? Icons.hourglass_empty : Icons.wifi),
            title: const Text('Probar conexión'),
            subtitle: const Text('Verifica que la URL y Key funcionen'),
            onTap: _isTesting ? null : _testConnection,
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Restablecer a valores por defecto'),
            subtitle: const Text('Borra configuración guardada'),
            onTap: _resetConfig,
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
            subtitle: Text('Lector QR/Código de barras para sistema POS'),
          ),
          const ListTile(
            leading: Icon(Icons.business),
            title: Text('Sistema'),
            subtitle: Text('Sistema POS - MVP primera versión'),
          ),
          const Divider(),

          // Database setup
          const _SectionHeader(title: 'Base de datos'),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Estructura de tablas'),
            subtitle: const Text('Ver SQL de creación de tablas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSqlDialog(context),
          ),
        ],
      ),
    );
  }
}