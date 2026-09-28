import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/visit_session_model.dart';
import '../../models/stage_model.dart';
import '../../services/pdf_report_service.dart';
import '../../theme/app_colors.dart';

class PdfReportScreen extends StatelessWidget {
  final VisitSessionModel visit;
  final List<StageModel> stages;

  const PdfReportScreen({
    super.key,
    required this.visit,
    required this.stages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reporte Membretado Oficial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.navy),
            tooltip: 'Compartir Reporte',
            onPressed: () async {
              final pdfData = await PdfReportService.generateVisitReport(
                visit: visit,
                stages: stages,
              );
              await Printing.sharePdf(
                bytes: pdfData,
                filename: 'Reporte_${visit.folio}.pdf',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfReportService.generateVisitReport(
          visit: visit,
          stages: stages,
        ),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: 'Reporte_${visit.folio}.pdf',
        previewPageMargin: const EdgeInsets.all(12),
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
