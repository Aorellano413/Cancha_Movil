import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_service.dart';

class PdfReservasService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> generarPdfReservas() async {
    final pdf = pw.Document();

    final todasReservas = await _firestoreService.getReservasCompletas();

    final reservas = todasReservas.where((r) {
      final estado = (r['estado'] ?? '').toString().trim().toLowerCase();
      return estado == 'pagado';
    }).toList();

    int total = reservas.fold<int>(0, (sum, r) {
      final precioStr =
          r['cancha']?['price']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
              '0';
      final precio = int.tryParse(precioStr) ?? 0;
      return sum + precio;
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text(
              'Reporte de Reservas',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                _header(),
                ...reservas.map((r) => _row(r)).toList(),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Text(
                  'TOTAL: ${_formatoMoneda(total)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.TableRow _row(Map<String, dynamic> r) {
    String fecha = '-';
    if (r['fechaReserva'] is Timestamp) {
      fecha = DateFormat('dd/MM/yyyy')
          .format((r['fechaReserva'] as Timestamp).toDate());
    }

    final hora = r['horaReserva'] ?? '-';
    final sedeNombre = r['sede']?['title'] ?? 'Sede';
    final canchaNombre = r['cancha']?['title'] ?? 'Cancha';
    final precioStr =
        r['cancha']?['price']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
            '0';
    final precio = int.tryParse(precioStr) ?? 0;

    return pw.TableRow(
      children: [
        _cell(sedeNombre),
        _cell(fecha),
        _cell(hora),
        _cell(canchaNombre),
        _cell(_formatoMoneda(precio)),
      ],
    );
  }

  pw.TableRow _header() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _headerCell('Sede'),
        _headerCell('Fecha'),
        _headerCell('Hora'),
        _headerCell('Cancha'),
        _headerCell('Monto'),
      ],
    );
  }

  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        softWrap: true,
      ),
    );
  }

  String _formatoMoneda(int valor) {
    final format = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return '${format.format(valor)} COP';
  }
}
