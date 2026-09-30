import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../services/pdf_report_service.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<ProductModel> _products = [];
  Map<String, dynamic> _stats = {'totalProducts': 0, 'totalValue': 0.0, 'criticalCount': 0};
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final list = await DatabaseHelper.instance.getProducts();
      final stats = await DatabaseHelper.instance.getStatistics();
      if (mounted) {
        setState(() {
          _products = list;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    }
  }

  void _openProductForm({ProductModel? product}) {
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final brandCtrl = TextEditingController(text: product?.brand ?? '');
    final locationCtrl = TextEditingController(text: product?.location ?? 'Estante A-1');
    final costCtrl = TextEditingController(text: product?.purchasePrice.toString() ?? '');
    final priceCtrl = TextEditingController(text: product?.salePrice.toString() ?? '');
    final taxCtrl = TextEditingController(text: product?.taxPercentage.toString() ?? '19');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final minStockCtrl = TextEditingController(text: product?.minStock.toString() ?? '5');
    final reorderCtrl = TextEditingController(text: product?.reorderPoint.toString() ?? '10');
    final batchCtrl = TextEditingController(text: product?.batchNumber ?? 'LOTE-001');
    final expCtrl = TextEditingController(text: product?.expirationDate ?? '2026-12-31');
    final supplierCtrl = TextEditingController(text: product?.supplier ?? '');

    String category = product?.category ?? 'General';
    String status = product?.status ?? 'Activo';

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            top: 20, left: 16, right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product == null ? 'Registrar Producto' : 'Editar Producto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField(
                          controller: skuCtrl,
                          label: 'Código / SKU',
                          icon: Icons.qr_code_rounded,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModalTextField(
                          controller: brandCtrl,
                          label: 'Marca',
                          icon: Icons.branding_watermark_outlined,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildModalTextField(
                    controller: nameCtrl,
                    label: 'Nombre del Producto',
                    icon: Icons.shopping_bag_outlined,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: category,
                          decoration: _inputDecoration('Categoría', Icons.category_outlined),
                          items: ['General', 'Alimentos', 'Herramientas', 'Insumos', 'Insumos Agrícolas']
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          onChanged: (val) => setModalState(() => category = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModalTextField(
                          controller: locationCtrl,
                          label: 'Ubicación Bodega',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildModalTextField(
                          controller: costCtrl,
                          label: 'Costo Compra',
                          icon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: _buildModalTextField(
                          controller: priceCtrl,
                          label: 'Precio Venta',
                          icon: Icons.sell_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: _buildModalTextField(
                          controller: taxCtrl,
                          label: '% IVA',
                          icon: Icons.percent_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildModalTextField(
                          controller: stockCtrl,
                          label: 'Stock Act.',
                          icon: Icons.inventory_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: _buildModalTextField(
                          controller: minStockCtrl,
                          label: 'Stock Mín.',
                          icon: Icons.trending_down_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: _buildModalTextField(
                          controller: reorderCtrl,
                          label: 'Reorden',
                          icon: Icons.autorenew_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField(
                          controller: batchCtrl,
                          label: 'Nº Lote',
                          icon: Icons.pin_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModalTextField(
                          controller: expCtrl,
                          label: 'Fecha Vencimiento',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField(
                          controller: supplierCtrl,
                          label: 'Proveedor',
                          icon: Icons.local_shipping_outlined,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: status,
                          decoration: _inputDecoration('Estado', Icons.verified_outlined),
                          items: ['Activo', 'Descontinuado', 'En Cuarentena']
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          onChanged: (val) => setModalState(() => status = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Guardar Producto',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final model = ProductModel(
                            id: product?.id,
                            userId: widget.user.id,
                            sku: skuCtrl.text.trim(),
                            name: nameCtrl.text.trim(),
                            brand: brandCtrl.text.trim(),
                            category: category,
                            location: locationCtrl.text.trim(),
                            purchasePrice: double.parse(costCtrl.text),
                            salePrice: double.parse(priceCtrl.text),
                            taxPercentage: double.parse(taxCtrl.text),
                            stock: int.parse(stockCtrl.text),
                            minStock: int.parse(minStockCtrl.text),
                            reorderPoint: int.parse(reorderCtrl.text),
                            batchNumber: batchCtrl.text.trim(),
                            expirationDate: expCtrl.text.trim(),
                            supplier: supplierCtrl.text.trim(),
                            status: status,
                            createdAt: product?.createdAt ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          );

                          if (product == null) {
                            await DatabaseHelper.instance.insertProduct(model);
                          } else {
                            await DatabaseHelper.instance.updateProduct(model);
                          }

                          if (!mounted) return;
                          Navigator.pop(ctx);
                          _loadData();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(product == null ? 'Producto registrado con éxito' : 'Producto actualizado correctamente'),
                                ],
                              ),
                              backgroundColor: Colors.green.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 10),
            const Text('Eliminar Registro'),
          ],
        ),
        content: Text(
          '¿Está seguro de eliminar "${product.name}" de la base de datos local?',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Colors.blueGrey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await DatabaseHelper.instance.deleteProduct(product.id!);
              if (!mounted) return;
              Navigator.pop(ctx);
              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${product.name}" fue eliminado del sistema'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Gestión de Inventario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Exportar Reporte PDF',
            onPressed: () {
              if (_products.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No hay registros guardados para generar el reporte'),
                    backgroundColor: Colors.orange.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              PdfReportService.generateAndPrintReport(
                context: context,
                products: _products,
                userName: widget.user.fullName.isNotEmpty ? widget.user.fullName : widget.user.email,
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      drawer: AppDrawer(user: widget.user),
      body: Column(
        children: [
          // Contenedor principal con fondo degradado y textura visual para las estadísticas
          // Banner minimalista de métricas clave
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B), // Azul slate elegante y sobrio
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen General',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Total Ítems',
                          value: '${_stats['totalProducts']}',
                          icon: Icons.inventory_2_outlined,
                          iconColor: const Color(0xFF2563EB),
                          bgColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Valor Total',
                          value: _currency.format(_stats['totalValue']),
                          icon: Icons.attach_money_rounded,
                          iconColor: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Stock Bajo',
                          value: '${_stats['criticalCount']}',
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFDC2626),
                          bgColor: const Color(0xFFFEE2E2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50)))
                : _products.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _products.length,
              itemBuilder: (ctx, i) {
                final p = _products[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: p.isLowStock ? Colors.red.shade200 : Colors.grey.shade200,
                      width: p.isLowStock ? 1.5 : 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: p.isLowStock ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          p.isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                          color: p.isLowStock ? const Color(0xFFDC2626) : const Color(0xFF475569),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        '${p.name} (${p.brand})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text(
                              'SKU: ${p.sku}',
                              style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: p.isLowStock ? Colors.red.shade50 : Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Stock: ${p.stock}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: p.isLowStock ? Colors.red.shade700 : Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDetailItem('Costo Compra', _currency.format(p.purchasePrice)),
                                  _buildDetailItem('Precio + IVA', _currency.format(p.priceWithTax), isBold: true),
                                  _buildDetailItem('Lote', p.batchNumber),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDetailItem('Proveedor', p.supplier),
                                  _buildDetailItem('Vencimiento', p.expirationDate, color: Colors.red.shade700),
                                  _buildStatusChip(p.status),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2C3E50),
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('Editar'),
                                    onPressed: () => _openProductForm(product: p),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      foregroundColor: Colors.red.shade700,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                    label: const Text('Eliminar'),
                                    onPressed: () => _confirmDeleteProduct(p),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Widget animado con movimiento flotante
            _AnimatedKawaiiBasket(),
            SizedBox(height: 24),
            Text(
              'No hay productos aquí',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tu inventario se encuentra vacío por el momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.blueGrey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;

    switch (status) {
      case 'Activo':
        chipColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'Descontinuado':
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
      default:
        chipColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 12),
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11),
      prefixIcon: Icon(icon, color: Colors.blueGrey.shade400, size: 16),
      prefixIconConstraints: const BoxConstraints(minWidth: 28),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
      ),
    );
  }
}

class _AnimatedKawaiiBasket extends StatefulWidget {
  const _AnimatedKawaiiBasket();

  @override
  State<_AnimatedKawaiiBasket> createState() => _AnimatedKawaiiBasketState();
}

class _AnimatedKawaiiBasketState extends State<_AnimatedKawaiiBasket>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Control de la duración del movimiento (flotado suave de 2 segundos)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Movimiento vertical constante de -6px a +6px
    _animation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: SizedBox(
        width: 160,
        height: 140,
        child: CustomPaint(
          painter: _KawaiiBasketPainter(),
        ),
      ),
    );
  }
}

class _KawaiiBasketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Fondo suave azulado / mancha
    final bgPaint = Paint()
      ..color = const Color(0xFFD6EEFF)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 5), width: 130, height: 85),
      bgPaint,
    );
    canvas.drawCircle(Offset(center.dx + 50, center.dy - 35), 8, bgPaint);
    canvas.drawCircle(Offset(center.dx - 45, center.dy + 30), 5, bgPaint);

    // Pincel para bordes oscuros
    final strokePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Asa de la canasta
    final handlePath = Path();
    handlePath.addArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 22), width: 44, height: 38),
      3.14,
      3.14,
    );
    canvas.drawPath(handlePath, strokePaint);

    // Cuerpo de la canasta
    final basketPath = Path();
    basketPath.moveTo(center.dx - 55, center.dy - 20);
    basketPath.lineTo(center.dx + 55, center.dy - 20);
    basketPath.lineTo(center.dx + 42, center.dy + 35);
    basketPath.lineTo(center.dx - 42, center.dy + 35);
    basketPath.close();

    canvas.drawPath(basketPath, fillPaint);
    canvas.drawPath(basketPath, strokePaint);

    // Ojos kawaii
    final eyePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 18, center.dy + 2), 3.5, eyePaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 2), 3.5, eyePaint);

    // Cachetes rosados
    final blushPaint = Paint()
      ..color = const Color(0xFFFFB2B2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 26, center.dy + 10), 4.5, blushPaint);
    canvas.drawCircle(Offset(center.dx + 26, center.dy + 10), 4.5, blushPaint);

    // Boca neutra
    canvas.drawLine(
      Offset(center.dx - 7, center.dy + 9),
      Offset(center.dx + 7, center.dy + 9),
      strokePaint..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KpiBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Círculos decorativos de fondo con opacidad suave
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 1.1), 50, paint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Patrón de líneas diagonales suaves
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.4, 0);

    path.moveTo(size.width * 0.6, size.height);
    path.lineTo(size.width, size.height * 0.3);

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}