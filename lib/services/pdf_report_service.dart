import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/visit_session_model.dart';
import '../models/stage_model.dart';

class PdfReportService {
  static Future<Uint8List> generateVisitReport({
    required VisitSessionModel visit,
    required List<StageModel> stages,
  }) async {
    final pdf = pw.Document();
    final stats = visit.calculateCollaboratorStats(stages);
    final overallConversion = visit.overallConversionRate(stages);

    final fontRegular = await PdfGoogleFonts.plusJakartaSansRegular();
    final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
    final fontSemiBold = await PdfGoogleFonts.plusJakartaSansSemiBold();

    final brandRed = PdfColor.fromHex('#C8102E');
    final brandNavy = PdfColor.fromHex('#14213D');
    final neutralLight = PdfColor.fromHex('#F4F6F9');
    final textDark = PdfColor.fromHex('#1E293B');
    final textGray = PdfColor.fromHex('#64748B');

    final completedGroups = visit.groups.where((g) => g.isCompleted).toList();
    final totalPeople = completedGroups.fold<int>(0, (sum, g) => sum + g.peopleCount);
    final totalPurchases = completedGroups.where((g) => g.isPurchaseMade(stages)).length;

    // Calcular promedio de tiempo a primera atención
    final withResponse = completedGroups.where((g) => g.firstAttentionTime != null).toList();
    final avgResponseSeconds = withResponse.isNotEmpty
        ? withResponse.fold<int>(0, (sum, g) => sum + g.secondsToFirstAttention) / withResponse.length
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          fontFallback: [fontRegular, fontSemiBold],
        ),
        header: (context) => _buildHeader(visit, brandRed, brandNavy, fontBold, fontRegular),
        footer: (context) => _buildFooter(context, brandNavy, textGray, fontRegular),
        build: (context) => [
          pw.SizedBox(height: 12),

          // Resumen Ejecutivo de Métricas
          _buildExecutiveSummary(
            totalGroups: completedGroups.length,
            totalPeople: totalPeople,
            totalPurchases: totalPurchases,
            conversionRate: overallConversion,
            avgResponseSeconds: avgResponseSeconds,
            brandRed: brandRed,
            brandNavy: brandNavy,
            neutralLight: neutralLight,
            fontBold: fontBold,
            fontRegular: fontRegular,
          ),

          pw.SizedBox(height: 18),

          // TÍTULO: Estadísticas de Conversión por Colaborador
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: brandNavy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  'TRAZABILIDAD Y CONVERSIÓN DE VENTA POR COLABORADOR',
                  style: pw.TextStyle(color: PdfColors.white, font: fontBold, fontSize: 11),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // TABLA DE CONVERSIÓN POR COLABORADOR
          _buildCollaboratorStatsTable(stats, brandRed, brandNavy, neutralLight, fontBold, fontRegular),

          pw.SizedBox(height: 16),

          // METODOLOGÍA: DESGLOSE DE ETAPAS OBSERVADAS (DOBLE G & EMBUDO)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: brandRed,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  'CUMPLIMIENTO DE PROTOCOLO: ETAPAS DOBLE G & EMBUDO',
                  style: pw.TextStyle(color: PdfColors.white, font: fontBold, fontSize: 11),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),
          _buildStagesSummary(stages, completedGroups, fontBold, fontRegular),

          pw.SizedBox(height: 16),

          // NOTAS Y OBSERVACIONES DE RH
          pw.Text(
            'OBSERVACIONES Y RECOMENDACIONES DE RECURSOS HUMANOS',
            style: pw.TextStyle(font: fontBold, fontSize: 10, color: brandNavy),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: neutralLight,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            child: pw.Text(
              visit.generalNotes.isNotEmpty
                  ? visit.generalNotes
                  : 'Se llevó a cabo la auditoría de piso conforme a los estándares de atención, calidez y técnica de ventas establecidos para la empresa La García Zapatería. Se recomienda dar seguimiento a los puntos de oportunidad identificados en el embudo comercial.',
              style: pw.TextStyle(fontSize: 9.5, color: textDark, font: fontRegular),
            ),
          ),

          pw.SizedBox(height: 26),

          // SECCIÓN FORMAL DE FIRMAS CON HOJA MEMBRETADA
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'VALIDEZ Y CONFORMIDAD DEL SEGUIMIENTO',
              style: pw.TextStyle(font: fontBold, fontSize: 10, color: brandNavy, letterSpacing: 0.5),
            ),
          ),
          pw.SizedBox(height: 16),

          _buildSignatureSection(visit, fontBold, fontRegular),
        ],
      ),
    );

    return pdf.save();
  }

  // Encabezado con Hoja Membretada
  static pw.Widget _buildHeader(
    VisitSessionModel visit,
    PdfColor brandRed,
    PdfColor brandNavy,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Banda de color superior institucional
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Container(height: 6, color: brandRed),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(height: 6, color: brandNavy),
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Logotipo y Título de Membrete
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'LA GARCÍA',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 22,
                        color: brandRed,
                        letterSpacing: 1.5,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: brandNavy,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'ZAPATERÍA',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 9, font: fontBold),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'DEPARTAMENTO DE RECURSOS HUMANOS Y CALIDAD DE SERVICIO',
                  style: pw.TextStyle(fontSize: 7.5, color: brandNavy, font: fontBold),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: brandRed, width: 1.2),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    'FOLIO: ${visit.folio}',
                    style: pw.TextStyle(font: fontBold, fontSize: 9, color: brandRed),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Fecha: ${dateFormat.format(visit.startTime)}',
                  style: pw.TextStyle(fontSize: 8.5, font: fontRegular, color: PdfColor.fromHex('#475569')),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColor.fromHex('#CBD5E1'), thickness: 0.8),
        pw.SizedBox(height: 6),

        // Metadatos de la Visita
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F8FAFC'),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildMetaItem('Sucursal Auditada:', visit.branchName, fontBold, fontRegular),
                  pw.SizedBox(height: 3),
                  _buildMetaItem('Encargado de Sucursal:', visit.branchManagerName, fontBold, fontRegular),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildMetaItem('Auditor RH:', visit.auditorName, fontBold, fontRegular),
                  pw.SizedBox(height: 3),
                  _buildMetaItem(
                    'Horario:',
                    '${timeFormat.format(visit.startTime)} - ${visit.endTime != null ? timeFormat.format(visit.endTime!) : "En curso"}',
                    fontBold,
                    fontRegular,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMetaItem(String label, String value, pw.Font fontBold, pw.Font fontRegular) {
    return pw.Row(
      children: [
        pw.Text(
          '$label ',
          style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromHex('#334155')),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColor.fromHex('#0F172A')),
        ),
      ],
    );
  }

  // Resumen Ejecutivo de Métricas
  static pw.Widget _buildExecutiveSummary({
    required int totalGroups,
    required int totalPeople,
    required int totalPurchases,
    required double conversionRate,
    required double avgResponseSeconds,
    required PdfColor brandRed,
    required PdfColor brandNavy,
    required PdfColor neutralLight,
    required pw.Font fontBold,
    required pw.Font fontRegular,
  }) {
    return pw.Row(
      children: [
        _buildMetricBox('Total Grupos', '$totalGroups', 'grupos observados', brandNavy, neutralLight, fontBold, fontRegular),
        pw.SizedBox(width: 8),
        _buildMetricBox('Personas', '$totalPeople', 'afluencia total', brandNavy, neutralLight, fontBold, fontRegular),
        pw.SizedBox(width: 8),
        _buildMetricBox('Ventas Cerradas', '$totalPurchases', 'compras concretadas', brandRed, neutralLight, fontBold, fontRegular),
        pw.SizedBox(width: 8),
        _buildMetricBox('Conversión Global', '${conversionRate.toStringAsFixed(1)}%', 'compraron / atendidos', brandRed, neutralLight, fontBold, fontRegular),
        pw.SizedBox(width: 8),
        _buildMetricBox('1ª Atención', '${avgResponseSeconds.toStringAsFixed(0)}s', 'tiempo promedio', brandNavy, neutralLight, fontBold, fontRegular),
      ],
    );
  }

  static pw.Widget _buildMetricBox(
    String title,
    String value,
    String subtitle,
    PdfColor accentColor,
    PdfColor bgColor,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        ),
        child: pw.Column(
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 7.5, font: fontRegular, color: PdfColor.fromHex('#64748B'))),
            pw.SizedBox(height: 3),
            pw.Text(value, style: pw.TextStyle(fontSize: 14, font: fontBold, color: accentColor)),
            pw.SizedBox(height: 2),
            pw.Text(subtitle, style: pw.TextStyle(fontSize: 6, font: fontRegular, color: PdfColor.fromHex('#94A3B8'))),
          ],
        ),
      ),
    );
  }

  // Tabla de Estadísticas de Conversión por Colaborador
  static pw.Widget _buildCollaboratorStatsTable(
    List<CollaboratorAuditStats> stats,
    PdfColor brandRed,
    PdfColor brandNavy,
    PdfColor neutralLight,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    if (stats.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        alignment: pw.Alignment.center,
        child: pw.Text('No hay datos concluidos de colaboradores en esta sesión.', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.8),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
          children: [
            _buildTableHeaderCell('Colaborador / Asesor', fontBold),
            _buildTableHeaderCell('Atendidos', fontBold, align: pw.TextAlign.center),
            _buildTableHeaderCell('Compras', fontBold, align: pw.TextAlign.center),
            _buildTableHeaderCell('% Conversión Venta', fontBold, align: pw.TextAlign.center),
            _buildTableHeaderCell('1ª Atención Prom.', fontBold, align: pw.TextAlign.center),
            _buildTableHeaderCell('Cumplimiento Doble G', fontBold, align: pw.TextAlign.center),
            _buildTableHeaderCell('Cumplimiento Embudo', fontBold, align: pw.TextAlign.center),
          ],
        ),

        // Filas por Colaborador
        ...stats.map((s) {
          final isHighConversion = s.conversionRate >= 50.0;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: brandNavy,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                      child: pw.Text(
                        s.collaboratorCode,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 8, font: fontBold),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Text(
                        s.collaboratorName,
                        style: pw.TextStyle(fontSize: 8.5, font: fontBold),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTableCell('${s.attendedCount} clientes', fontRegular, align: pw.TextAlign.center),
              _buildTableCell('${s.boughtCount} ventas', fontRegular, align: pw.TextAlign.center),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: isHighConversion ? PdfColor.fromHex('#DEF7EC') : PdfColor.fromHex('#FDE8E8'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      '${s.conversionRate.toStringAsFixed(1)}%',
                      style: pw.TextStyle(
                        fontSize: 9,
                        font: fontBold,
                        color: isHighConversion ? PdfColor.fromHex('#03543F') : PdfColor.fromHex('#9B1C1C'),
                      ),
                    ),
                  ),
                ),
              ),
              _buildTableCell('${s.avgResponseTimeSeconds.toStringAsFixed(0)} seg', fontRegular, align: pw.TextAlign.center),
              _buildTableCell('${s.dobleGCompliance.toStringAsFixed(0)}%', fontRegular, align: pw.TextAlign.center),
              _buildTableCell('${s.embudoCompliance.toStringAsFixed(0)}%', fontRegular, align: pw.TextAlign.center),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text, pw.Font fontBold, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColor.fromHex('#334155')),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font fontRegular, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColor.fromHex('#1E293B')),
      ),
    );
  }

  // Resumen de Etapas de Protocolo Doble G & Embudo
  static pw.Widget _buildStagesSummary(
    List<StageModel> stages,
    List<dynamic> completedGroups,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.8),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
          children: [
            _buildTableHeaderCell('Metodología', fontBold),
            _buildTableHeaderCell('Etapa del Protocolo', fontBold),
            _buildTableHeaderCell('Descripción / Conducta Clave', fontBold),
            _buildTableHeaderCell('Cumplimiento', fontBold, align: pw.TextAlign.center),
          ],
        ),
        ...stages.map((stg) {
          int yesCount = 0;
          int observedCount = 0;

          for (final grp in completedGroups) {
            final res = grp.stageResults[stg.id];
            if (res != null && res != StageResultState.unobserved) {
              observedCount++;
              if (res == StageResultState.yes) {
                yesCount++;
              }
            }
          }

          final pct = observedCount > 0 ? (yesCount / observedCount) * 100 : 0.0;
          final isDobleG = stg.category == StageCategory.dobleG;

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  isDobleG ? 'DOBLE G' : 'EMBUDO',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    font: fontBold,
                    color: isDobleG ? PdfColor.fromHex('#14213D') : PdfColor.fromHex('#C8102E'),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(stg.title, style: pw.TextStyle(fontSize: 8, font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(stg.description, style: pw.TextStyle(fontSize: 7.5, font: fontRegular, color: PdfColor.fromHex('#475569'))),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '$yesCount/$observedCount (${pct.toStringAsFixed(0)}%)',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 8, font: fontBold, color: pct >= 70 ? PdfColor.fromHex('#047857') : PdfColor.fromHex('#B91C1C')),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Sección de Firmas de Validez (Encargado, Colaborador y RH)
  static pw.Widget _buildSignatureSection(
    VisitSessionModel visit,
    pw.Font fontBold,
    pw.Font fontRegular,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Firma 1: Encargado de Sucursal
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 38), // Espacio para firma física / digital
                pw.Divider(color: PdfColor.fromHex('#94A3B8'), thickness: 1),
                pw.SizedBox(height: 4),
                pw.Text(
                  visit.branchManagerName,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontBold, fontSize: 8),
                ),
                pw.Text(
                  'Encargado(a) de Sucursal',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColor.fromHex('#64748B')),
                ),
                pw.Text(
                  'Firma y Sello de Conformidad',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontRegular, fontSize: 6.5, color: PdfColor.fromHex('#94A3B8')),
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 12),

        // Firma 2: Colaborador / Vendedor Representante
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 38),
                pw.Divider(color: PdfColor.fromHex('#94A3B8'), thickness: 1),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Colaborador(a) Evaluado(a)',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontBold, fontSize: 8),
                ),
                pw.Text(
                  'Asesor de Ventas en Piso',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColor.fromHex('#64748B')),
                ),
                pw.Text(
                  'Firma de Enterado y Compromiso',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontRegular, fontSize: 6.5, color: PdfColor.fromHex('#94A3B8')),
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 12),

        // Firma 3: Auditor de Recursos Humanos (RH)
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 38),
                pw.Divider(color: PdfColor.fromHex('#94A3B8'), thickness: 1),
                pw.SizedBox(height: 4),
                pw.Text(
                  visit.auditorName,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontBold, fontSize: 8),
                ),
                pw.Text(
                  'Recursos Humanos (RH)',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColor.fromHex('#64748B')),
                ),
                pw.Text(
                  'Auditoría y Certificación de Calidad',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontRegular, fontSize: 6.5, color: PdfColor.fromHex('#94A3B8')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Pie de página
  static pw.Widget _buildFooter(
    pw.Context context,
    PdfColor brandNavy,
    PdfColor textGray,
    pw.Font fontRegular,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'La García Zapatería • Sistema de Gestión y Trazabilidad de RH',
              style: pw.TextStyle(font: fontRegular, fontSize: 7, color: textGray),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(font: fontRegular, fontSize: 7, color: textGray),
            ),
          ],
        ),
      ],
    );
  }
}
