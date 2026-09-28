import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/visit_session_model.dart';
import '../../providers/visit_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/stat_progress_bar.dart';
import 'pdf_report_screen.dart';

class VisitStatsScreen extends StatelessWidget {
  final VisitSessionModel visit;

  const VisitStatsScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final visitProv = context.watch<VisitProvider>();
    final stages = visitProv.stages;
    final stats = visit.calculateCollaboratorStats(stages);
    final overallConversion = visit.overallConversionRate(stages);

    final completedGroups = visit.groups.where((g) => g.isCompleted).toList();
    final totalPeople = completedGroups.fold<int>(0, (sum, g) => sum + g.peopleCount);
    final totalPurchases = completedGroups.where((g) => g.isPurchaseMade(stages)).length;

    final withResponse = completedGroups.where((g) => g.firstAttentionTime != null).toList();
    final avgResponseSeconds = withResponse.isNotEmpty
        ? withResponse.fold<int>(0, (sum, g) => sum + g.secondsToFirstAttention) / withResponse.length
        : 0.0;

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resultados y Conversión de Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
            tooltip: 'Generar Reporte PDF Membretado',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfReportScreen(visit: visit, stages: stages),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera Resumen de la Sucursal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          visit.branchName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          visit.folio,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Encargado(a): ${visit.branchManagerName}  •  Auditor RH: ${visit.auditorName}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fecha: ${dateFormat.format(visit.startTime)}  •  Horario: ${timeFormat.format(visit.startTime)} - ${visit.endTime != null ? timeFormat.format(visit.endTime!) : "Concluido"}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid de Métricas Principales (KPIs)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                KpiCard(
                  title: 'Conversión Global',
                  value: '${overallConversion.toStringAsFixed(1)}%',
                  subtitle: '$totalPurchases compras de ${completedGroups.length} clientes',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.primary,
                ),
                KpiCard(
                  title: '1ª Atención Prom.',
                  value: '${avgResponseSeconds.toStringAsFixed(0)}s',
                  subtitle: avgResponseSeconds <= 10 ? 'Meta ≤10s alcanzada' : 'Demora detectada',
                  icon: Icons.timer_outlined,
                  iconColor: avgResponseSeconds <= 10 ? AppColors.statusYes : AppColors.leatherAmber,
                ),
                KpiCard(
                  title: 'Grupos Auditados',
                  value: '${completedGroups.length}',
                  subtitle: '$totalPeople personas en tienda',
                  icon: Icons.groups_rounded,
                  iconColor: AppColors.navy,
                ),
                KpiCard(
                  title: 'Ventas Concretadas',
                  value: '$totalPurchases',
                  subtitle: 'Compras en mostrador',
                  icon: Icons.shopping_bag_outlined,
                  iconColor: AppColors.statusYes,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // GRÁFICO COMPARATIVO: Clientes Atendidos vs Compras por Colaborador
            if (stats.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversión de Venta por Colaborador',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comparativa visual de clientes atendidos vs clientes que compraron',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildLegendItem(AppColors.navy, 'Clientes Atendidos'),
                        const SizedBox(width: 14),
                        _buildLegendItem(AppColors.primary, 'Compras Concretadas'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Gráfico de Barras con fl_chart
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (stats.map((s) => s.attendedCount).fold<int>(0, (max, v) => v > max ? v : max) + 1).toDouble(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final s = stats[group.x.toInt()];
                                final label = rodIndex == 0 ? 'Atendidos: ${s.attendedCount}' : 'Compraron: ${s.boughtCount}';
                                return BarTooltipItem(
                                  label,
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < stats.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        stats[idx].collaboratorCode,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                getTitlesWidget: (val, meta) {
                                  return Text(
                                    val.toInt().toString(),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppColors.cardBorder,
                              strokeWidth: 0.8,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: stats.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final s = entry.value;
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: s.attendedCount.toDouble(),
                                  color: AppColors.navy,
                                  width: 14,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                                BarChartRodData(
                                  toY: s.boughtCount.toDouble(),
                                  color: AppColors.primary,
                                  width: 14,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // DESGLOSE INDIVIDUAL POR COLABORADOR
            Text(
              'Trazabilidad Detallada por Colaborador',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cálculo de conversión de venta, cumplimiento de protocolo y tiempos de respuesta.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            ...stats.map((collabStat) => _buildCollaboratorDetailCard(collabStat)),

            const SizedBox(height: 24),

            // BOTÓN DE REPORTE MEMBRETADO PDF
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reporte Oficial con Hoja Membretada',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Incluye membrete institucional y firmas de Encargado, Colaborador y RH.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfReportScreen(visit: visit, stages: stages),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Generar e Imprimir Reporte PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCollaboratorDetailCard(CollaboratorAuditStats s) {
    final isHigh = s.conversionRate >= 50.0;
    final badgeColor = isHigh ? AppColors.statusYes : (s.conversionRate >= 30.0 ? AppColors.leatherAmber : AppColors.dangerRed);
    final badgeBg = isHigh ? AppColors.statusYesBg : (s.conversionRate >= 30.0 ? const Color(0xFFFEF3C7) : AppColors.statusNoBg);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Colaborador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.navy,
                    radius: 18,
                    child: Text(
                      s.collaboratorCode,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.collaboratorName,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy),
                      ),
                      Text(
                        'Atendió ${s.attendedCount} clientes  •  ${s.totalPeopleServed} personas en total',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),

              // Badge de Conversión
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${s.conversionRate.toStringAsFixed(1)}%',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      'CONVERSIÓN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Métricas de Cumplimiento
          StatProgressBar(
            label: 'Conversión: ${s.boughtCount} compras cerradas de ${s.attendedCount} atendidos',
            percentage: s.conversionRate,
            barColor: badgeColor,
          ),
          const SizedBox(height: 10),

          StatProgressBar(
            label: 'Cumplimiento Protocolo Doble G',
            percentage: s.dobleGCompliance,
            barColor: AppColors.navy,
          ),
          const SizedBox(height: 10),

          StatProgressBar(
            label: 'Cumplimiento Embudo de Ventas',
            percentage: s.embudoCompliance,
            barColor: AppColors.primary,
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiempo promedio a 1ª atención:',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '${s.avgResponseTimeSeconds.toStringAsFixed(0)} segundos (Meta ≤10s)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: s.avgResponseTimeSeconds <= 10 ? AppColors.statusYes : AppColors.leatherAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
