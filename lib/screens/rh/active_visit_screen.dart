import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/stage_model.dart';
import '../../providers/visit_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/stage_toggle_tile.dart';
import 'visit_stats_screen.dart';

class ActiveVisitScreen extends StatefulWidget {
  const ActiveVisitScreen({super.key});

  @override
  State<ActiveVisitScreen> createState() => _ActiveVisitScreenState();
}

class _ActiveVisitScreenState extends State<ActiveVisitScreen> {
  final _timeFormat = DateFormat('hh:mm:ss a');

  void _showFinishVisitDialog() {
    final visit = context.read<VisitProvider>();
    final notesController = TextEditingController(text: visit.currentVisit?.generalNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Finalizar Visita de Auditoría',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Deseas concluir la supervisión de piso y generar las estadísticas de conversión por colaborador?',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones generales de RH',
                  hintText: 'Anota sugerencias, retroalimentación o incidencias de piso...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Continuar en Piso'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await visit.completeVisit(notesController.text.trim());
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => VisitStatsScreen(visit: visit.viewingVisit!),
                    ),
                  );
                }
              },
              child: const Text('Concluir y Ver Estadísticas'),
            ),
          ],
        );
      },
    );
  }

  void _showIncidentDialog() {
    final visit = context.read<VisitProvider>();
    final group = visit.currentGroup;
    if (group == null) return;

    final reasons = [
      'Cliente no encontró su talla/número',
      'Asesores ocupados / tiempo de espera alto',
      'Precio / Falta de promoción',
      'Cliente solo explorando / mirando',
      'Modelo no disponible en bodega',
      'Desacuerdo en método de pago',
    ];
    String selectedReason = reasons.first;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.report_problem_rounded, color: AppColors.dangerRed),
                  const SizedBox(width: 8),
                  Text(
                    'Registrar Incidencia / Abandono',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Motivo principal por el que el cliente no concretó compra:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    isExpanded: true,
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedReason = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Detalle adicional (opcional)',
                      hintText: 'Ej. Buscaba botín 25 piel negra...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
                  onPressed: () {
                    final note = noteController.text.trim().isNotEmpty
                        ? '$selectedReason - ${noteController.text.trim()}'
                        : selectedReason;
                    visit.reportIncident(note);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incidencia registrada para este grupo.')),
                    );
                  },
                  child: const Text('Guardar Incidencia'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCollaboratorPicker() {
    final visit = context.read<VisitProvider>();
    final collabs = visit.branchCollaborators;
    final group = visit.currentGroup;
    if (group == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Asignar Asesor(a) de Calzado',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: collabs.length,
                    itemBuilder: (context, idx) {
                      final c = collabs[idx];
                      final isSelected = c.id == group.collaboratorId;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AppColors.primary : AppColors.navy,
                          child: Text(
                            c.code,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        title: Text(
                          c.fullName,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          c.position,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                        onTap: () {
                          visit.updateCollaborator(c);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visit = context.watch<VisitProvider>();
    final currentVisit = visit.currentVisit;

    if (currentVisit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seguimiento en Piso')),
        body: const Center(child: Text('No hay visita activa.')),
      );
    }

    final group = visit.currentGroup;
    final now = visit.nowTicker;
    final visitDuration = now.difference(currentVisit.startTime);
    final visitMinutes = visitDuration.inMinutes;
    final visitSeconds = visitDuration.inSeconds % 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 65,
        titleSpacing: 16,
        title: Row(
          children: [
            const BrandLogo(fontSize: 18, showSubtitle: false),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusYesBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.statusYes.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.statusYes,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'En piso: ${visitMinutes.toString().padLeft(2, '0')}:${visitSeconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusYes,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _showFinishVisitDialog,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Finalizar Visita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sub-barra informativa con sucursal y folio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 16, color: AppColors.navy),
                    const SizedBox(width: 6),
                    Text(
                      currentVisit.branchName,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                  ],
                ),
                Text(
                  currentVisit.folio,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Carrusel de Grupos Auditados (Permite saltar entre Grupo A, B, C...)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: AppColors.surfaceSubtle,
            child: Row(
              children: [
                // Botón + Nuevo Grupo
                InkWell(
                  onTap: () => visit.addNewGroup(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Nuevo Grupo',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1),
                const SizedBox(width: 8),

                // Lista horizontal de grupos
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentVisit.groups.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final grp = currentVisit.groups[idx];
                      final isSelected = idx == visit.activeGroupIndex;

                      return InkWell(
                        onTap: () => visit.selectGroup(idx),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.navy : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.navy : AppColors.cardBorder,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                grp.displayName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              if (grp.isCompleted) ...[
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.check_circle,
                                  size: 13,
                                  color: isSelected ? Colors.white : AppColors.statusYes,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenido principal del grupo actual
          if (group != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta Principal del Grupo
                    _buildActiveGroupCard(visit, group, now),
                    const SizedBox(height: 16),

                    // Encabezado de Etapas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ETAPAS DOBLE G & EMBUDO',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '1 TOQUE = SÍ · 2º = NO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Lista de Etapas
                    ...visit.stages.map((stg) {
                      final state = group.stageResults[stg.id] ?? StageResultState.unobserved;
                      return StageToggleTile(
                        stage: stg,
                        state: state,
                        onTap: () => visit.cycleStage(stg.id),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Botones de acción del Grupo
                    Row(
                      children: [
                        // Botón Finalizar Grupo
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              visit.finalizeCurrentGroup();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${group.displayName} guardado exitosamente.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              group.isCompleted ? Icons.check_circle : Icons.check,
                              size: 18,
                            ),
                            label: Text(
                              group.isCompleted ? '${group.displayName} (Completado)' : 'Finalizar ${group.displayName}',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: group.isCompleted ? AppColors.statusYes : AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Botón Incidencia / Abandono
                        Container(
                          decoration: BoxDecoration(
                            color: group.hasIncident ? AppColors.dangerLight : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: group.hasIncident ? AppColors.dangerRed : AppColors.cardBorder,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.error_outline_rounded,
                              color: group.hasIncident ? AppColors.dangerRed : AppColors.textSecondary,
                            ),
                            tooltip: 'Registrar Incidencia / Abandono',
                            onPressed: _showIncidentDialog,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tarjeta de Datos y Selectores del Grupo
  Widget _buildActiveGroupCard(VisitProvider visit, dynamic group, DateTime now) {
    final arrivalTimeFormatted = _timeFormat.format(group.arrivalTime);
    final groupDuration = (group.completedTime ?? now).difference(group.arrivalTime);
    final groupMinutes = groupDuration.inMinutes;
    final groupSecs = groupDuration.inSeconds % 60;
    final durationStr = '${groupMinutes.toString().padLeft(2, '0')}:${groupSecs.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fila Superior: Letra, Nombre del Grupo, Hora y Cronómetro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        group.groupLetter,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grupo #${group.groupNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        arrivalTimeFormatted,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Cronómetro de Piso
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.navy),
                    const SizedBox(width: 5),
                    Text(
                      durationStr,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // LLEGADA Y AJUSTES (-1m, -2m)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'LLEGADA: ',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    arrivalTimeFormatted,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => visit.adjustArrivalTime(-1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text('-1m', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => visit.adjustArrivalTime(-2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text('-2m', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 1ª ATENCIÓN (Registro interactivo de tiempo de respuesta)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: group.firstAttentionTime != null ? AppColors.statusYesBg : AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: group.firstAttentionTime != null ? AppColors.statusYes.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            group.firstAttentionTime != null ? Icons.check_circle_outline : Icons.hourglass_top_rounded,
                            size: 15,
                            color: group.firstAttentionTime != null ? AppColors.statusYes : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            group.firstAttentionTime != null
                                ? '1ª ATENCIÓN RECIBIDA'
                                : '1ª ATENCIÓN: Esperando atención...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: group.firstAttentionTime != null ? AppColors.statusYes : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        group.firstAttentionTime != null
                            ? '${group.secondsToFirstAttention} segundos en piso (Meta ≤10s)'
                            : '${group.totalDurationSeconds}s transcurridos sin atención',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (group.firstAttentionTime == null)
                  ElevatedButton(
                    onPressed: () => visit.markFirstAttention(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Registrar 1ª Atención'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // SELECTORES RÁPIDOS: PERS. | VEND. | SEGM. | ZONA
          Row(
            children: [
              // PERS. (Personas: 1, 2, 3+)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PERS.', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [1, 2, 3].map((cnt) {
                        final isSel = group.peopleCount == cnt;
                        return Expanded(
                          child: InkWell(
                            onTap: () => visit.updatePeopleCount(cnt),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.navy : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  cnt == 3 ? '3+' : '$cnt',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // VEND. (Asignación de Vendedor)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VEND.', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _showCollaboratorPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group.collaboratorCode.isNotEmpty ? group.collaboratorCode : 'V1',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.navy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // SEGM. (Segmento)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SEGM.', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: group.segment,
                          isDense: true,
                          isExpanded: true,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          items: ['Damas', 'Caballeros', 'Niños', 'Deportivo', 'Confort'].map((s) {
                            return DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) visit.updateSegment(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ZONA (A, B, C)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ZONA', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['A', 'B', 'C'].map((z) {
                        final isSel = group.zone == z;
                        return Expanded(
                          child: InkWell(
                            onTap: () => visit.updateZone(z),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  z,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
