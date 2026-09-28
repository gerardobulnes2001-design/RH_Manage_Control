import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/branch_model.dart';
import '../../models/collaborator_model.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_logo.dart';
import '../auth/login_screen.dart';
import '../rh/rh_dashboard_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // DIALOGO SUCURSAL (Crear / Editar)
  void _showBranchDialog([BranchModel? branch]) {
    final nameCtrl = TextEditingController(text: branch?.name ?? '');
    final codeCtrl = TextEditingController(text: branch?.code ?? '');
    final addressCtrl = TextEditingController(text: branch?.address ?? '');
    final cityCtrl = TextEditingController(text: branch?.city ?? 'Villahermosa, Tabasco');
    final managerCtrl = TextEditingController(text: branch?.managerName ?? '');
    final phoneCtrl = TextEditingController(text: branch?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            branch == null ? 'Nueva Sucursal' : 'Editar Sucursal',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre de Sucursal')),
                const SizedBox(height: 10),
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Código (ej. SUC-05)')),
                const SizedBox(height: 10),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Dirección completa')),
                const SizedBox(height: 10),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Ciudad y Estado')),
                const SizedBox(height: 10),
                TextField(controller: managerCtrl, decoration: const InputDecoration(labelText: 'Encargado(a) de Sucursal')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono de contacto')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty) return;
                final admin = context.read<AdminProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                await admin.saveBranch(
                  id: branch?.id,
                  name: nameCtrl.text.trim(),
                  code: codeCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  managerName: managerCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Sucursal guardada correctamente.')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // DIALOGO COLABORADOR (Crear / Editar)
  void _showCollaboratorDialog([CollaboratorModel? collab]) {
    final admin = context.read<AdminProvider>();
    final codeCtrl = TextEditingController(text: collab?.code ?? 'V1');
    final nameCtrl = TextEditingController(text: collab?.fullName ?? '');
    final posCtrl = TextEditingController(text: collab?.position ?? 'Asesor de Calzado');
    BranchModel selectedBranch = admin.branches.firstWhere(
      (b) => b.id == collab?.branchId,
      orElse: () => admin.branches.isNotEmpty ? admin.branches.first : BranchModel(id: '', name: 'General', code: '', address: '', city: '', managerName: '', phone: ''),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                collab == null ? 'Nuevo Colaborador' : 'Editar Colaborador',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Código / Clave (ej. V1, V2)')),
                    const SizedBox(height: 10),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
                    const SizedBox(height: 10),
                    TextField(controller: posCtrl, decoration: const InputDecoration(labelText: 'Puesto / Especialidad')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<BranchModel>(
                      value: selectedBranch,
                      items: admin.branches.map((b) => DropdownMenuItem(value: b, child: Text(b.name, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setDState(() => selectedBranch = val);
                      },
                      decoration: const InputDecoration(labelText: 'Sucursal Asignada'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);
                    await admin.saveCollaborator(
                      id: collab?.id,
                      code: codeCtrl.text.trim(),
                      fullName: nameCtrl.text.trim(),
                      branchId: selectedBranch.id,
                      branchName: selectedBranch.name,
                      position: posCtrl.text.trim(),
                    );
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Colaborador guardado correctamente.')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DIALOGO ETAPA (Crear / Editar)
  void _showStageDialog([StageModel? stage]) {
    final titleCtrl = TextEditingController(text: stage?.title ?? '');
    final descCtrl = TextEditingController(text: stage?.description ?? '');
    StageCategory cat = stage?.category ?? StageCategory.dobleG;
    bool isKey = stage?.isKeyConversion ?? false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                stage == null ? 'Nueva Etapa de Protocolo' : 'Editar Etapa',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<StageCategory>(
                      value: cat,
                      items: const [
                        DropdownMenuItem(value: StageCategory.dobleG, child: Text('DOBLE G')),
                        DropdownMenuItem(value: StageCategory.embudo, child: Text('EMBUDO')),
                      ],
                      onChanged: (v) => setDState(() => cat = v!),
                      decoration: const InputDecoration(labelText: 'Metodología'),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título de la Etapa')),
                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción / Conducta Clave')),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      value: isKey,
                      title: const Text('¿Es la etapa clave de cierre de venta (Compra)?', style: TextStyle(fontSize: 12)),
                      onChanged: (v) => setDState(() => isKey = v ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty) return;
                    final admin = context.read<AdminProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);
                    await admin.saveStage(
                      id: stage?.id,
                      category: cat,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      orderIndex: stage?.orderIndex ?? (admin.stages.length + 1),
                      isKeyConversion: isKey,
                    );
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Etapa actualizada correctamente.')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DIALOGO USUARIO (Crear / Editar)
  void _showUserDialog([UserModel? user]) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    UserRole role = user?.role ?? UserRole.rh;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                user == null ? 'Nuevo Usuario' : 'Editar Usuario',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
                    const SizedBox(height: 10),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Correo Institucional')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<UserRole>(
                      value: role,
                      items: const [
                        DropdownMenuItem(value: UserRole.admin, child: Text('Administrador (Control Total)')),
                        DropdownMenuItem(value: UserRole.rh, child: Text('Recursos Humanos (RH)')),
                      ],
                      onChanged: (v) => setDState(() => role = v!),
                      decoration: const InputDecoration(labelText: 'Nivel Administrativo'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                    final admin = context.read<AdminProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);
                    await admin.saveUser(
                      id: user?.id,
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      role: role,
                    );
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Usuario guardado.')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel de Administración', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy)),
            Text('Edición total de parámetros de la empresa', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          // Acceso a módulo RH
          IconButton(
            icon: const Icon(Icons.assignment_outlined, color: AppColors.primary),
            tooltip: 'Ir a Módulo de Supervisión RH',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RhDashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.navy),
            tooltip: 'Restablecer datos predeterminados (Demo Seed)',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restablecer Datos Demo'),
                  content: const Text('¿Deseas restaurar todas las sucursales, colaboradores y etapas a los valores iniciales?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(ctx);
                        navigator.pop();
                        await admin.restoreDefaults();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Datos restaurados al estado original.')),
                        );
                      },
                      child: const Text('Restablecer'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.store_rounded, size: 18), text: 'Sucursales'),
            Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Colaboradores'),
            Tab(icon: Icon(Icons.linear_scale_rounded, size: 18), text: 'Etapas Doble G'),
            Tab(icon: Icon(Icons.manage_accounts_rounded, size: 18), text: 'Usuarios'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _showBranchDialog();
              break;
            case 1:
              _showCollaboratorDialog();
              break;
            case 2:
              _showStageDialog();
              break;
            case 3:
              _showUserDialog();
              break;
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: SUCURSALES
          _buildBranchesTab(admin),

          // TAB 2: COLABORADORES
          _buildCollaboratorsTab(admin),

          // TAB 3: ETAPAS DOBLE G & EMBUDO
          _buildStagesTab(admin),

          // TAB 4: USUARIOS
          _buildUsersTab(admin),
        ],
      ),
    );
  }

  Widget _buildBranchesTab(AdminProvider admin) {
    if (admin.branches.isEmpty) {
      return const Center(child: Text('No hay sucursales configuradas.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admin.branches.length,
      itemBuilder: (context, idx) {
        final b = admin.branches[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(b.code, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            title: Text(b.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text('${b.address} • ${b.city}', style: const TextStyle(fontSize: 12)),
                Text('Encargado: ${b.managerName} | Tel: ${b.phone}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.navy), onPressed: () => _showBranchDialog(b)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.dangerRed),
                  onPressed: () => admin.deleteBranch(b.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollaboratorsTab(AdminProvider admin) {
    if (admin.collaborators.isEmpty) {
      return const Center(child: Text('No hay colaboradores registrados.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admin.collaborators.length,
      itemBuilder: (context, idx) {
        final c = admin.collaborators[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              child: Text(c.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            title: Text(c.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy)),
            subtitle: Text('${c.position} • ${c.branchName}', style: const TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.navy), onPressed: () => _showCollaboratorDialog(c)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.dangerRed),
                  onPressed: () => admin.deleteCollaborator(c.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStagesTab(AdminProvider admin) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admin.stages.length,
      itemBuilder: (context, idx) {
        final s = admin.stages[idx];
        final isDobleG = s.category == StageCategory.dobleG;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDobleG ? AppColors.navy : AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isDobleG ? 'DOBLE G' : 'EMBUDO',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Text(s.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy)),
                if (s.isKeyConversion) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Meta Venta', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            subtitle: Text(s.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.navy), onPressed: () => _showStageDialog(s)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.dangerRed),
                  onPressed: () => admin.deleteStage(s.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab(AdminProvider admin) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admin.users.length,
      itemBuilder: (context, idx) {
        final u = admin.users[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: u.isAdmin ? AppColors.navy : AppColors.primary,
              child: Icon(u.isAdmin ? Icons.admin_panel_settings : Icons.badge, color: Colors.white, size: 20),
            ),
            title: Text(u.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy)),
            subtitle: Text('${u.email} • ${u.roleDisplayName}', style: const TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.navy), onPressed: () => _showUserDialog(u)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.dangerRed),
                  onPressed: () => admin.deleteUser(u.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
