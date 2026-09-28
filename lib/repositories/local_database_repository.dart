import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/collaborator_model.dart';
import '../models/stage_model.dart';
import '../models/group_interaction_model.dart';
import '../models/visit_session_model.dart';
import 'database_repository.dart';

class LocalDatabaseRepository implements DatabaseRepository {
  static const String _keyUsers = 'lgz_users';
  static const String _keyBranches = 'lgz_branches';
  static const String _keyCollaborators = 'lgz_collaborators';
  static const String _keyStages = 'lgz_stages';
  static const String _keyVisits = 'lgz_visits';

  final Uuid _uuid = const Uuid();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<UserModel>> getUsers() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyUsers);
    if (jsonStr == null) {
      final initialUsers = _getInitialUsers();
      await _saveUsersList(initialUsers);
      return initialUsers;
    }
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((item) => UserModel.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _saveUsersList(users);
  }

  @override
  Future<void> deleteUser(String id) async {
    final users = await getUsers();
    users.removeWhere((u) => u.id == id);
    await _saveUsersList(users);
  }

  Future<void> _saveUsersList(List<UserModel> list) async {
    final prefs = await _prefs;
    final data = list.map((u) => u.toMap()).toList();
    await prefs.setString(_keyUsers, jsonEncode(data));
  }

  // Branches
  @override
  Future<List<BranchModel>> getBranches() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyBranches);
    if (jsonStr == null) {
      final initial = _getInitialBranches();
      await _saveBranchesList(initial);
      return initial;
    }
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((item) => BranchModel.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveBranch(BranchModel branch) async {
    final branches = await getBranches();
    final index = branches.indexWhere((b) => b.id == branch.id);
    if (index >= 0) {
      branches[index] = branch;
    } else {
      branches.add(branch);
    }
    await _saveBranchesList(branches);
  }

  @override
  Future<void> deleteBranch(String id) async {
    final branches = await getBranches();
    branches.removeWhere((b) => b.id == id);
    await _saveBranchesList(branches);
  }

  Future<void> _saveBranchesList(List<BranchModel> list) async {
    final prefs = await _prefs;
    final data = list.map((b) => b.toMap()).toList();
    await prefs.setString(_keyBranches, jsonEncode(data));
  }

  // Collaborators
  @override
  Future<List<CollaboratorModel>> getCollaborators({String? branchId}) async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyCollaborators);
    List<CollaboratorModel> all;
    if (jsonStr == null) {
      all = _getInitialCollaborators();
      await _saveCollaboratorsList(all);
    } else {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      all = list.map((item) => CollaboratorModel.fromMap(item as Map<String, dynamic>)).toList();
    }
    if (branchId != null && branchId.isNotEmpty) {
      return all.where((c) => c.branchId == branchId).toList();
    }
    return all;
  }

  @override
  Future<void> saveCollaborator(CollaboratorModel collaborator) async {
    final collabs = await getCollaborators();
    final index = collabs.indexWhere((c) => c.id == collaborator.id);
    if (index >= 0) {
      collabs[index] = collaborator;
    } else {
      collabs.add(collaborator);
    }
    await _saveCollaboratorsList(collabs);
  }

  @override
  Future<void> deleteCollaborator(String id) async {
    final collabs = await getCollaborators();
    collabs.removeWhere((c) => c.id == id);
    await _saveCollaboratorsList(collabs);
  }

  Future<void> _saveCollaboratorsList(List<CollaboratorModel> list) async {
    final prefs = await _prefs;
    final data = list.map((c) => c.toMap()).toList();
    await prefs.setString(_keyCollaborators, jsonEncode(data));
  }

  // Stages
  @override
  Future<List<StageModel>> getStages() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyStages);
    if (jsonStr == null) {
      final initial = _getInitialStages();
      await _saveStagesList(initial);
      return initial;
    }
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    final stages = list.map((item) => StageModel.fromMap(item as Map<String, dynamic>)).toList();
    stages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return stages;
  }

  @override
  Future<void> saveStage(StageModel stage) async {
    final stages = await getStages();
    final index = stages.indexWhere((s) => s.id == stage.id);
    if (index >= 0) {
      stages[index] = stage;
    } else {
      stages.add(stage);
    }
    await _saveStagesList(stages);
  }

  @override
  Future<void> deleteStage(String id) async {
    final stages = await getStages();
    stages.removeWhere((s) => s.id == id);
    await _saveStagesList(stages);
  }

  Future<void> _saveStagesList(List<StageModel> list) async {
    final prefs = await _prefs;
    final data = list.map((s) => s.toMap()).toList();
    await prefs.setString(_keyStages, jsonEncode(data));
  }

  // Visits
  @override
  Future<List<VisitSessionModel>> getVisits() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyVisits);
    if (jsonStr == null) {
      final initial = _getInitialVisits();
      await _saveVisitsList(initial);
      return initial;
    }
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((item) => VisitSessionModel.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<VisitSessionModel?> getVisitById(String id) async {
    final visits = await getVisits();
    try {
      return visits.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveVisit(VisitSessionModel visit) async {
    final visits = await getVisits();
    final index = visits.indexWhere((v) => v.id == visit.id);
    if (index >= 0) {
      visits[index] = visit;
    } else {
      visits.insert(0, visit);
    }
    await _saveVisitsList(visits);
  }

  @override
  Future<void> deleteVisit(String id) async {
    final visits = await getVisits();
    visits.removeWhere((v) => v.id == id);
    await _saveVisitsList(visits);
  }

  Future<void> _saveVisitsList(List<VisitSessionModel> list) async {
    final prefs = await _prefs;
    final data = list.map((v) => v.toMap()).toList();
    await prefs.setString(_keyVisits, jsonEncode(data));
  }

  @override
  Future<void> resetToSeedData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyUsers);
    await prefs.remove(_keyBranches);
    await prefs.remove(_keyCollaborators);
    await prefs.remove(_keyStages);
    await prefs.remove(_keyVisits);

    await _saveUsersList(_getInitialUsers());
    await _saveBranchesList(_getInitialBranches());
    await _saveCollaboratorsList(_getInitialCollaborators());
    await _saveStagesList(_getInitialStages());
    await _saveVisitsList(_getInitialVisits());
  }

  // Seed Data Initializers
  List<UserModel> _getInitialUsers() {
    return [
      UserModel(
        id: 'user_admin_01',
        name: 'Lic. Fernando García',
        email: 'admin@lagarcia.com',
        role: UserRole.admin,
      ),
      UserModel(
        id: 'user_rh_01',
        name: 'Mtra. Carolina Ruiz',
        email: 'rh@lagarcia.com',
        role: UserRole.rh,
        branchName: 'Auditoría Corporativa',
      ),
    ];
  }

  List<BranchModel> _getInitialBranches() {
    return [
      BranchModel(
        id: 'branch_pino_suarez',
        name: 'Sucursal Centro Histórico',
        code: 'SUC-01',
        address: 'José Ma. Pino Suárez 614-A, Col. Centro',
        city: 'Villahermosa, Tabasco',
        managerName: 'Ing. Carlos Ramón Castillo',
        phone: '993 312 4589',
      ),
      BranchModel(
        id: 'branch_altabrisa',
        name: 'Sucursal Plaza Altabrisa',
        code: 'SUC-02',
        address: 'Periférico Carlos Pellicer Cámara 129, Local 42',
        city: 'Villahermosa, Tabasco',
        managerName: 'Lic. Mariana Valdez',
        phone: '993 351 9022',
      ),
      BranchModel(
        id: 'branch_cardenas',
        name: 'Sucursal Cárdenas Centro',
        code: 'SUC-03',
        address: 'Av. Juárez 302, Zona Comercial',
        city: 'H. Cárdenas, Tabasco',
        managerName: 'Lic. Gabriel Méndez',
        phone: '937 372 1105',
      ),
      BranchModel(
        id: 'branch_galerias',
        name: 'Sucursal Galerías Tabasco 2000',
        code: 'SUC-04',
        address: 'Paseo Tabasco 1405, Plaza Galerías',
        city: 'Villahermosa, Tabasco',
        managerName: 'Lic. Patricia Domínguez',
        phone: '993 316 7744',
      ),
    ];
  }

  List<CollaboratorModel> _getInitialCollaborators() {
    return [
      CollaboratorModel(
        id: 'collab_01',
        code: 'V1',
        fullName: 'Carlos Mendoza',
        branchId: 'branch_pino_suarez',
        branchName: 'Sucursal Centro Histórico',
        position: 'Asesor Especialista Damas',
      ),
      CollaboratorModel(
        id: 'collab_02',
        code: 'V2',
        fullName: 'Sofía Hernández',
        branchId: 'branch_pino_suarez',
        branchName: 'Sucursal Centro Histórico',
        position: 'Asesora Línea Deportiva & Confort',
      ),
      CollaboratorModel(
        id: 'collab_03',
        code: 'V3',
        fullName: 'Roberto Garza',
        branchId: 'branch_pino_suarez',
        branchName: 'Sucursal Centro Histórico',
        position: 'Asesor Caballeros & Vestir',
      ),
      CollaboratorModel(
        id: 'collab_04',
        code: 'V4',
        fullName: 'Elena Morales',
        branchId: 'branch_pino_suarez',
        branchName: 'Sucursal Centro Histórico',
        position: 'Asesora Escolar & Infantil',
      ),
      CollaboratorModel(
        id: 'collab_05',
        code: 'V1',
        fullName: 'Daniel Ortega',
        branchId: 'branch_altabrisa',
        branchName: 'Sucursal Plaza Altabrisa',
        position: 'Asesor Calzado General',
      ),
    ];
  }

  List<StageModel> _getInitialStages() {
    return [
      StageModel(
        id: 'stage_10s_reconocimiento',
        category: StageCategory.dobleG,
        title: '10s Reconocimiento',
        description: 'Contacto visual, sonrisa y saludo de bienvenida antes de 10 segundos.',
        orderIndex: 1,
        targetSeconds: 10,
      ),
      StageModel(
        id: 'stage_atencion',
        category: StageCategory.embudo,
        title: 'Atención',
        description: 'Disposición activa y postura receptiva hacia el cliente.',
        orderIndex: 2,
      ),
      StageModel(
        id: 'stage_conecta',
        category: StageCategory.dobleG,
        title: 'Conecta',
        description: 'Indagación amable del estilo, ocasión de uso y número de calzado.',
        orderIndex: 3,
      ),
      StageModel(
        id: 'stage_prueba_calzado',
        category: StageCategory.embudo,
        title: 'Prueba de Calzado',
        description: 'Llevar los pares a tiempo, ofrecer calzador y verificar confort.',
        orderIndex: 4,
      ),
      StageModel(
        id: 'stage_2da_opcion',
        category: StageCategory.dobleG,
        title: '2ª Opción',
        description: 'Presentar una alternativa de calzado o producto complementario (limpiador/plantillas).',
        orderIndex: 5,
      ),
      StageModel(
        id: 'stage_compra',
        category: StageCategory.embudo,
        title: 'Compra',
        description: 'Concreción de la venta y acompañamiento entusiasta a punto de cobro.',
        orderIndex: 6,
        isKeyConversion: true, // Clave para la tasa de conversión
      ),
      StageModel(
        id: 'stage_experiencia_wow',
        category: StageCategory.dobleG,
        title: 'Experiencia WOW',
        description: 'Despedida memorable, entrega de bolsa y sincero agradecimiento.',
        orderIndex: 7,
      ),
    ];
  }

  List<VisitSessionModel> _getInitialVisits() {
    final now = DateTime.now();
    final stages = _getInitialStages();

    // Visita demostrativa completada con trazabilidad completa
    final sampleVisitId = 'visit_seed_01';
    final sampleGroups = [
      GroupInteractionModel(
        id: 'grp_01',
        visitId: sampleVisitId,
        groupLetter: 'A',
        groupNumber: 1,
        arrivalTime: now.subtract(const Duration(minutes: 45)),
        startTrackingTime: now.subtract(const Duration(minutes: 45)),
        firstAttentionTime: now.subtract(const Duration(minutes: 44, seconds: 52)),
        peopleCount: 2,
        collaboratorId: 'collab_01',
        collaboratorCode: 'V1',
        collaboratorName: 'Carlos Mendoza',
        segment: 'Damas',
        zone: 'A',
        stageResults: {
          'stage_10s_reconocimiento': StageResultState.yes,
          'stage_atencion': StageResultState.yes,
          'stage_conecta': StageResultState.yes,
          'stage_prueba_calzado': StageResultState.yes,
          'stage_2da_opcion': StageResultState.yes,
          'stage_compra': StageResultState.yes,
          'stage_experiencia_wow': StageResultState.yes,
        },
        completedTime: now.subtract(const Duration(minutes: 32)),
        isCompleted: true,
      ),
      GroupInteractionModel(
        id: 'grp_02',
        visitId: sampleVisitId,
        groupLetter: 'B',
        groupNumber: 2,
        arrivalTime: now.subtract(const Duration(minutes: 30)),
        startTrackingTime: now.subtract(const Duration(minutes: 30)),
        firstAttentionTime: now.subtract(const Duration(minutes: 29, seconds: 40)),
        peopleCount: 1,
        collaboratorId: 'collab_01',
        collaboratorCode: 'V1',
        collaboratorName: 'Carlos Mendoza',
        segment: 'Damas',
        zone: 'B',
        stageResults: {
          'stage_10s_reconocimiento': StageResultState.yes,
          'stage_atencion': StageResultState.yes,
          'stage_conecta': StageResultState.yes,
          'stage_prueba_calzado': StageResultState.yes,
          'stage_2da_opcion': StageResultState.no,
          'stage_compra': StageResultState.no,
          'stage_experiencia_wow': StageResultState.yes,
        },
        completedTime: now.subtract(const Duration(minutes: 20)),
        isCompleted: true,
      ),
      GroupInteractionModel(
        id: 'grp_03',
        visitId: sampleVisitId,
        groupLetter: 'C',
        groupNumber: 3,
        arrivalTime: now.subtract(const Duration(minutes: 25)),
        startTrackingTime: now.subtract(const Duration(minutes: 25)),
        firstAttentionTime: now.subtract(const Duration(minutes: 24, seconds: 50)),
        peopleCount: 3,
        collaboratorId: 'collab_02',
        collaboratorCode: 'V2',
        collaboratorName: 'Sofía Hernández',
        segment: 'Deportivo',
        zone: 'C',
        stageResults: {
          'stage_10s_reconocimiento': StageResultState.yes,
          'stage_atencion': StageResultState.yes,
          'stage_conecta': StageResultState.yes,
          'stage_prueba_calzado': StageResultState.yes,
          'stage_2da_opcion': StageResultState.yes,
          'stage_compra': StageResultState.yes,
          'stage_experiencia_wow': StageResultState.yes,
        },
        completedTime: now.subtract(const Duration(minutes: 10)),
        isCompleted: true,
      ),
      GroupInteractionModel(
        id: 'grp_04',
        visitId: sampleVisitId,
        groupLetter: 'A',
        groupNumber: 4,
        arrivalTime: now.subtract(const Duration(minutes: 18)),
        startTrackingTime: now.subtract(const Duration(minutes: 18)),
        firstAttentionTime: now.subtract(const Duration(minutes: 17, seconds: 35)),
        peopleCount: 1,
        collaboratorId: 'collab_03',
        collaboratorCode: 'V3',
        collaboratorName: 'Roberto Garza',
        segment: 'Caballeros',
        zone: 'B',
        stageResults: {
          'stage_10s_reconocimiento': StageResultState.no,
          'stage_atencion': StageResultState.yes,
          'stage_conecta': StageResultState.yes,
          'stage_prueba_calzado': StageResultState.yes,
          'stage_2da_opcion': StageResultState.no,
          'stage_compra': StageResultState.yes,
          'stage_experiencia_wow': StageResultState.yes,
        },
        completedTime: now.subtract(const Duration(minutes: 5)),
        isCompleted: true,
      ),
    ];

    return [
      VisitSessionModel(
        id: sampleVisitId,
        folio: 'LGZ-VIS-2026-0038',
        branchId: 'branch_pino_suarez',
        branchName: 'Sucursal Centro Histórico',
        auditorId: 'user_rh_01',
        auditorName: 'Mtra. Carolina Ruiz',
        branchManagerName: 'Ing. Carlos Ramón Castillo',
        startTime: now.subtract(const Duration(minutes: 50)),
        endTime: now.subtract(const Duration(minutes: 5)),
        isCompleted: true,
        generalNotes: 'Excelente disposición del equipo. Se observa oportunidad de refuerzo en la etapa "2ª Opción" para incrementar el ticket promedio en calzado formal damas.',
        groups: sampleGroups,
      ),
    ];
  }
}
