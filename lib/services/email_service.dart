// lib/services/email_service.dart
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String smtpUser;
  final String appPassword;
  final String host;
  final int port;
  final bool ignoreBadCertificate;

  EmailService({
    required this.smtpUser,
    required this.appPassword,
    this.host = 'smtp.gmail.com',
    this.port = 587,
    this.ignoreBadCertificate = false,
  });

  SmtpServer _server() {
    return SmtpServer(
      host,
      port: port,
      username: smtpUser,
      password: appPassword,
      ignoreBadCertificate: ignoreBadCertificate,
    );
  }

  String _codigoReserva(DateTime fecha, String hora) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    final hh = hora.split(':').first.padLeft(2, '0');
    return 'RS-$y$m$d-$hh';
  }

  String _plantillaFactura({
    required String numero,
    required String fechaStr,
    required String nombreCliente,
    required List<Map<String, String>> items,
    String? subtotal,
    String? impuestos,
    required String total,
    required String logoCid,
  }) {
    const text = '#0F172A';
    const gray = '#374151';
    const lightGray = '#F3F4F6';
    const border = '#E5E7EB';
    const headerDark = '#1e3a8a';
    const primary = '#2563eb';

    final filas = items.map((it) {
      return '''
      <tr>
        <td style="padding:12px 10px;border-bottom:1px solid $border;color:$gray;">${it['Descripcion']}</td>
        <td align="center" style="padding:12px 10px;border-bottom:1px solid $border;color:$gray;">${it['Cantidad']}</td>
        <td align="right" style="padding:12px 10px;border-bottom:1px solid $border;color:$gray;">${it['Precio']}</td>
        <td align="right" style="padding:12px 10px;border-bottom:1px solid $border;color:$gray;">${it['Total']}</td>
      </tr>
      ''';
    }).join();

    return '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="color-scheme" content="light only">
  </head>
  <body style="margin:0;padding:0;background:#ffffff;font-family:Arial,Helvetica,sans-serif;color:$text;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:24px 0;background:#ffffff;">
      <tr>
        <td align="center">
          <table role="presentation" width="720" cellpadding="0" cellspacing="0" style="max-width:720px;width:100%;padding:0 24px;">
            <tr>
              <td style="padding:16px 0 24px;border-bottom:3px solid $headerDark;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="left" style="vertical-align:middle;">
                      <img src="cid:$logoCid" alt="ReservaSports Logo" style="width:120px;height:120px;object-fit:contain;">
                    </td>
                    <td align="right" style="vertical-align:middle;">
                      <div style="font-size:48px;letter-spacing:1px;font-weight:900;color:$headerDark;margin-bottom:5px;">Reserva</div>
                      <div style="font-size:18px;color:$gray;">ReservaSports</div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:24px 0 8px;">
                <div style="font-size:14px;line-height:24px;color:$gray;">
                  <div><strong style="color:$headerDark;">Factura n°:</strong> $numero</div>
                  <div><strong style="color:$headerDark;">Fecha:</strong> $fechaStr</div>
                  <div><strong style="color:$headerDark;">Cliente:</strong> $nombreCliente</div>
                </div>
              </td>
            </tr>

            <tr>
              <td style="padding-top:16px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:separate;border-spacing:0;width:100%;">
                  <tr style="background:$headerDark;color:#ffffff;">
                    <th align="left" style="padding:15px 10px;font-size:14px;font-weight:600;">Descripción</th>
                    <th align="center" style="padding:15px 10px;font-size:14px;font-weight:600;width:120px;">Cantidad</th>
                    <th align="right" style="padding:15px 10px;font-size:14px;font-weight:600;width:140px;">Precio</th>
                    <th align="right" style="padding:15px 10px;font-size:14px;font-weight:600;width:140px;">Total</th>
                  </tr>
                  $filas
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:18px 0 8px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td></td>
                    <td align="right" style="width:260px;">
                      <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                        ${subtotal == null ? '' : '''
                        <tr>
                          <td style="padding:10px 8px;color:$gray;font-weight:600;">Subtotal</td>
                          <td align="right" style="padding:10px 8px;color:$text;">$subtotal</td>
                        </tr>
                        '''}
                        ${impuestos == null ? '' : '''
                        <tr>
                          <td style="padding:10px 8px;color:$gray;font-weight:600;">Impuestos</td>
                          <td align="right" style="padding:10px 8px;color:$text;">$impuestos</td>
                        </tr>
                        '''}
                        <tr>
                          <td style="padding:10px 8px;font-weight:900;color:$headerDark;border-top:2px solid $headerDark;font-size:18px;">TOTAL</td>
                          <td align="right" style="padding:10px 8px;font-weight:900;color:$headerDark;border-top:2px solid $headerDark;font-size:18px;">$total</td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:32px 20px 16px;background:$lightGray;border-radius:8px;margin-top:24px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                  <tr>
                    <td valign="top" style="width:100%;">
                      <div style="font-size:16px;font-weight:800;margin-bottom:10px;color:$headerDark;">Contacto:</div>
                      <div style="font-size:14px;color:$gray;line-height:24px;">
                        <div>(+57) 302 282 6211</div>
                        <div>reservasports5@gmail.com</div>
                        <div>Reservasports Valledupar - Cesar</div>
                      </div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:24px 0 24px;font-size:12px;color:$gray;text-align:center;border-top:1px solid $border;margin-top:16px;">
                © ${DateTime.now().year} ReservaSports. Correo automático, por favor no responder.
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
''';
  }

  Future<void> enviarCorreosReserva({
    required String correoUsuario,
    required String nombreUsuario,
    required DateTime fechaReserva,
    required String horaReserva,
    required String sedeNombre,
    required String canchaNombre,
    required String precio,
    required String correoAdmin,
  }) async {
    final server = _server();
    final numero = _codigoReserva(fechaReserva, horaReserva);
    final fechaLegible =
        '${fechaReserva.day.toString().padLeft(2, '0')} de ${_mes(fechaReserva.month)} de ${fechaReserva.year}';

    final precioSoloDigitos = precio.replaceAll(RegExp(r'[^0-9]'), '');
    final precioFmt = '\$$precioSoloDigitos';

    final items = <Map<String, String>>[
      {
        'Descripcion': 'Reserva $canchaNombre — $sedeNombre ($horaReserva)',
        'Cantidad': '1',
        'Precio': precioFmt,
        'Total': precioFmt,
      },
    ];

    const logoCidForHtml = 'logoReservaSports@cid';
    const logoCidForAttachment = '<$logoCidForHtml>';

    final Uint8List logoBytes = await _cargarLogoBytes();

    final htmlUsuario = _plantillaFactura(
      numero: numero,
      fechaStr: fechaLegible,
      nombreCliente: nombreUsuario,
      items: items,
      subtotal: precioFmt,
      total: precioFmt,
      logoCid: logoCidForHtml,
    );

    final mensajeUsuario = Message()
      ..from = Address(smtpUser, 'ReservaSports')
      ..recipients.add(correoUsuario)
      ..subject = 'Factura de reserva $numero — $fechaLegible $horaReserva'
      ..html = htmlUsuario;

    final attachmentUser = StreamAttachment(
      Stream.fromIterable([logoBytes]),
      'image/jpg',
      fileName: 'logoReservaSports.jpg',
    )
      ..location = Location.inline
      ..cid = logoCidForAttachment;

    mensajeUsuario.attachments.add(attachmentUser);

    final htmlAdmin = _plantillaFactura(
      numero: numero,
      fechaStr: fechaLegible,
      nombreCliente: nombreUsuario,
      items: items,
      subtotal: precioFmt,
      total: precioFmt,
      logoCid: logoCidForHtml,
    );

    final mensajeAdmin = Message()
      ..from = Address(smtpUser, 'ReservaSports')
      ..recipients.add(correoAdmin)
      ..subject = 'Nueva reserva $numero — $fechaLegible $horaReserva'
      ..html = htmlAdmin;

    final attachmentAdmin = StreamAttachment(
      Stream.fromIterable([logoBytes]),
      'image/png',
      fileName: 'logoReservaSports.jpg',
    )
      ..location = Location.inline
      ..cid = logoCidForAttachment;

    mensajeAdmin.attachments.add(attachmentAdmin);

    await send(mensajeUsuario, server);
    await send(mensajeAdmin, server);
  }

  Future<Uint8List> _cargarLogoBytes() async {
    final data = await rootBundle.load('lib/images/logoReservaSports.jpg');
    return data.buffer.asUint8List();
  }

  String _mes(int m) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final idx = (m - 1).clamp(0, 11).toInt();
    return meses[idx];
  }
}