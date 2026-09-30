import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';

// Servicio para la generación y descarga del reporte PDF
class PdfReportService {
  static Future<void> generateAndPrintReport({
    required BuildContext context,
    required List<ProductModel> products,
    required String userName,
  }) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final currentDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final double valorTotal = products.fold(0, (sum, item) => sum + item.totalValue);
    final int stockTotal = products.fold(0, (sum, item) => sum + item.stock);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INFORME GENERAL DE INVENTARIO',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    pw.Text('Sistema de Control e Inventario de Bodega',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Fecha: $currentDate', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Generado por: $userName', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.blueGrey400),
            pw.SizedBox(height: 10),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryBox('Total Productos', '${products.length}'),
                _buildSummaryBox('Unidades Totales', '$stockTotal'),
                _buildSummaryBox('Valorización Total', currency.format(valorTotal)),
              ],
            ),
            pw.SizedBox(height: 15),

            pw.TableHelper.fromTextArray(
              headers: ['SKU', 'Producto', 'Ubicación', 'Lote', 'Costo', 'P. Venta', 'Stock', 'Estado'],
              data: products.map((p) => [
                p.sku,
                '${p.name}\n(${p.brand})',
                p.location,
                p.batchNumber,
                currency.format(p.purchasePrice),
                currency.format(p.salePrice),
                '${p.stock}',
                p.status,
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Reporte Oficial - Documento Interno', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Reporte_Inventario_$currentDate.pdf',
    );
  }

  static pw.Widget _buildSummaryBox(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.indigo100),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        ],
      ),
    );
  }
}