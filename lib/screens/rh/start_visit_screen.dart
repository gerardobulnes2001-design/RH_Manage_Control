import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/branch_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visit_provider.dart';
import '../../theme/app_colors.dart';
import 'active_visit_screen.dart';

class StartVisitScreen extends StatefulWidget {
  const StartVisitScreen({super.key});

  @override
  State<StartVisitScreen> createState() => _StartVisitScreenState();
}

class _StartVisitScreenState extends State<StartVisitScreen> {
  BranchModel? _selectedBranch;
  final _managerController = TextEditingController();
  final _auditorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _auditorController.text = auth.currentUser?.name ?? 'Auditor RH';

    final admin = context.read<AdminProvider>();
    if (admin.branches.isNotEmpty) {
      _selectedBranch = admin.branches.first;
      _managerController.text = _selectedBranch!.managerName;
    }
  }

  @override
  void dispose() {
    _managerController.dispose();
    _auditorController.dispose();
    super.dispose();
  }

  void _onBranchChanged(BranchModel? branch) {
    if (branch != null) {
      setState(() {
        _selectedBranch = branch;
        _managerController.text = branch.managerName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final visit = context.watch<VisitProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva Visita de Auditoría'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado descriptivo
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Control de Seguimiento en Piso',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Selecciona la sucursal y verifica los responsables para registrar la trazabilidad.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Formulario
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos de la Visita',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Sucursal
                      Text(
                        'Sucursal a Supervisar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<BranchModel>(
                        value: _selectedBranch,
                        items: admin.branches.map((b) {
                          return DropdownMenuItem(
                            value: b,
                            child: Text('${b.code} - ${b.name}', style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: _onBranchChanged,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.store_rounded, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Encargado de Sucursal
                      Text(
                        'Encargado(a) de Sucursal en Turno',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _managerController,
                        decoration: const InputDecoration(
                          hintText: 'Nombre del encargado de sucursal',
                          prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Auditor RH
                      Text(
                        'Auditor(a) de Recursos Humanos',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _auditorController,
                        decoration: const InputDecoration(
                          hintText: 'Nombre de quien realiza el seguimiento',
                          prefixIcon: Icon(Icons.badge_outlined, color: AppColors.navy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botón Iniciar
                ElevatedButton.icon(
                  onPressed: (_selectedBranch == null || visit.isLoading)
                      ? null
                      : () async {
                          final nav = Navigator.of(context);
                          await visit.startNewVisit(
                            branch: _selectedBranch!,
                            auditorId: auth.currentUser?.id ?? 'rh_user',
                            auditorName: _auditorController.text.trim(),
                            branchManagerName: _managerController.text.trim(),
                          );
                          if (!mounted) return;
                          nav.pushReplacement(
                            MaterialPageRoute(builder: (_) => const ActiveVisitScreen()),
                          );
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text('Iniciar Seguimiento en Piso'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
