import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'firestore_service.dart';

class PdfReservasService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> generarPdfReservas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final pdf = pw.Document();

    final todasReservas = await _firestoreService.getReservasCompletas();
    final reservas = todasReservas.where((r) {
      final estado = (r['estado'] ?? '').toString().toLowerCase();
      if (estado != 'pagado') return false;

      if (r['fechaReserva'] is! Timestamp) return false;

      final fecha = (r['fechaReserva'] as Timestamp).toDate();

      return fecha.isAfter(
              fechaInicio.subtract(const Duration(seconds: 1))) &&
          fecha.isBefore(fechaFin.add(const Duration(seconds: 1)));
    }).toList();
    int total = reservas.fold<int>(0, (sum, r) {
      final precioStr = r['cancha']?['price']
              ?.toString()
              .replaceAll(RegExp(r'[^0-9]'), '') ??
          '0';
      return sum + (int.tryParse(precioStr) ?? 0);
    });

    final logoBytes = await rootBundle.load('lib/images/inder.png');
    final logo = logoBytes.buffer.asUint8List();

    final fechaGeneracion =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final rangoTexto =
        '${DateFormat('dd/MM/yyyy').format(fechaInicio)} - ${DateFormat('dd/MM/yyyy').format(fechaFin)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    height: 70,
                    width: 70,
                    child: pw.Image(pw.MemoryImage(logo)),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INDER',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Reporte de Reservas Pagadas',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Ciudad: Valledupar',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.Text('Fecha: $fechaGeneracion',
                      style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 16),
          pw.Text('Periodo: $rangoTexto',
              style: pw.TextStyle(fontSize: 10)),

          pw.SizedBox(height: 18),
          pw.Text(
            'RESERVAS PAGADAS',
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 6),
            height: 2,
            width: 130,
            color: PdfColors.black,
          ),

          pw.SizedBox(height: 18),
          pw.Table(
            columnWidths: {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(3),
              4: pw.FlexColumnWidth(2),
            },
            border: pw.TableBorder(
              horizontalInside:
                  pw.BorderSide(color: PdfColors.grey300),
            ),
            children: [
              _header(),
              ...List.generate(reservas.length, (i) {
                return _row(reservas[i], i);
              }),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 260,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL RECAUDADO',
                    style: pw.TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    _formatoMoneda(total),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
      );
    } else {
      await _guardarYAbrirPdf(pdf, 'INDER_RESERVAS.pdf');
    }
  }

  Future<void> _guardarYAbrirPdf(
      pw.Document pdf, String nombre) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombre');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  pw.TableRow _header() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _headerCell('Sede'),
        _headerCell('Fecha'),
        _headerCell('Hora'),
        _headerCell('Cancha'),
        _headerCell('Monto'),
      ],
    );
  }

  pw.TableRow _row(Map<String, dynamic> r, int index) {
    final fecha = DateFormat('dd/MM/yyyy')
        .format((r['fechaReserva'] as Timestamp).toDate());

    final bg = index.isEven ? PdfColors.grey100 : PdfColors.white;

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        _cell(r['sede']?['title'] ?? ''),
        _cell(fecha),
        _cell(r['horaReserva'] ?? ''),
        _cell(r['cancha']?['title'] ?? ''),
        _cell(_formatoMoneda(
            int.tryParse(r['cancha']?['price']
                    ?.toString()
                    .replaceAll(RegExp(r'[^0-9]'), '') ??
                '0') ??
            0)),
      ],
    );
  }

  pw.Widget _headerCell(String t) => pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          t,
          style: pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      );

  pw.Widget _cell(String t) => pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(t, style: const pw.TextStyle(fontSize: 9)),
      );

  String _formatoMoneda(int v) {
    final f = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return '${f.format(v)} COP';
  }
}
