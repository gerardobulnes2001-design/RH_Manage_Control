import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/collaborator_model.dart';
import '../models/stage_model.dart';
import '../models/visit_session_model.dart';
import 'database_repository.dart';
import 'local_database_repository.dart';

class SupabaseDatabaseRepository implements DatabaseRepository {
  final LocalDatabaseRepository _localFallback = LocalDatabaseRepository();

  SupabaseClient? get _client => SupabaseConfig.client;

  bool get isConnected => _client != null;

  // USERS
  @override
  Future<List<UserModel>> getUsers() async {
    final client = _client;
    if (client == null) return _localFallback.getUsers();

    try {
      final List<dynamic> data = await client.from('users').select().order('name');
      if (data.isEmpty) {
        // Si la tabla está vacía en Supabase, sincronizar datos base iniciales
        final initial = await _localFallback.getUsers();
        for (final u in initial) {
          await saveUser(u);
        }
        return initial;
      }
      return data.map((item) => _mapUserFromDb(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback local si hay error de red o permisos
      return _localFallback.getUsers();
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _localFallback.saveUser(user);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('users').upsert({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role.name,
        'branch_id': user.branchId,
        'branch_name': user.branchName,
        'is_active': user.isActive,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteUser(String id) async {
    await _localFallback.deleteUser(id);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('users').delete().eq('id', id);
    } catch (_) {}
  }

  // BRANCHES
  @override
  Future<List<BranchModel>> getBranches() async {
    final client = _client;
    if (client == null) return _localFallback.getBranches();

    try {
      final List<dynamic> data = await client.from('branches').select().order('code');
      if (data.isEmpty) {
        final initial = await _localFallback.getBranches();
        for (final b in initial) {
          await saveBranch(b);
        }
        return initial;
      }
      return data.map((item) => _mapBranchFromDb(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _localFallback.getBranches();
    }
  }

  @override
  Future<void> saveBranch(BranchModel branch) async {
    await _localFallback.saveBranch(branch);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('branches').upsert({
        'id': branch.id,
        'name': branch.name,
        'code': branch.code,
        'address': branch.address,
        'city': branch.city,
        'manager_name': branch.managerName,
        'phone': branch.phone,
        'is_active': branch.isActive,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteBranch(String id) async {
    await _localFallback.deleteBranch(id);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('branches').delete().eq('id', id);
    } catch (_) {}
  }

  // COLLABORATORS
  @override
  Future<List<CollaboratorModel>> getCollaborators({String? branchId}) async {
    final client = _client;
    if (client == null) return _localFallback.getCollaborators(branchId: branchId);

    try {
      var query = client.from('collaborators').select();
      if (branchId != null && branchId.isNotEmpty) {
        query = query.eq('branch_id', branchId);
      }
      final List<dynamic> data = await query.order('code');
      if (data.isEmpty) {
        final initial = await _localFallback.getCollaborators();
        for (final c in initial) {
          await saveCollaborator(c);
        }
        return branchId != null ? initial.where((c) => c.branchId == branchId).toList() : initial;
      }
      return data.map((item) => _mapCollabFromDb(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _localFallback.getCollaborators(branchId: branchId);
    }
  }

  @override
  Future<void> saveCollaborator(CollaboratorModel collaborator) async {
    await _localFallback.saveCollaborator(collaborator);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('collaborators').upsert({
        'id': collaborator.id,
        'code': collaborator.code,
        'full_name': collaborator.fullName,
        'branch_id': collaborator.branchId,
        'branch_name': collaborator.branchName,
        'position': collaborator.position,
        'is_active': collaborator.isActive,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteCollaborator(String id) async {
    await _localFallback.deleteCollaborator(id);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('collaborators').delete().eq('id', id);
    } catch (_) {}
  }

  // STAGES
  @override
  Future<List<StageModel>> getStages() async {
    final client = _client;
    if (client == null) return _localFallback.getStages();

    try {
      final List<dynamic> data = await client.from('stages').select().order('order_index');
      if (data.isEmpty) {
        final initial = await _localFallback.getStages();
        for (final s in initial) {
          await saveStage(s);
        }
        return initial;
      }
      return data.map((item) => _mapStageFromDb(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _localFallback.getStages();
    }
  }

  @override
  Future<void> saveStage(StageModel stage) async {
    await _localFallback.saveStage(stage);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('stages').upsert({
        'id': stage.id,
        'category': stage.category.name,
        'title': stage.title,
        'description': stage.description,
        'order_index': stage.orderIndex,
        'is_key_conversion': stage.isKeyConversion,
        'target_seconds': stage.targetSeconds,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteStage(String id) async {
    await _localFallback.deleteStage(id);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('stages').delete().eq('id', id);
    } catch (_) {}
  }

  // VISITS
  @override
  Future<List<VisitSessionModel>> getVisits() async {
    final client = _client;
    if (client == null) return _localFallback.getVisits();

    try {
      final List<dynamic> data = await client.from('visits').select().order('start_time', ascending: false);
      if (data.isEmpty) {
        final initial = await _localFallback.getVisits();
        for (final v in initial) {
          await saveVisit(v);
        }
        return initial;
      }
      return data.map((item) => _mapVisitFromDb(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _localFallback.getVisits();
    }
  }

  @override
  Future<VisitSessionModel?> getVisitById(String id) async {
    final client = _client;
    if (client == null) return _localFallback.getVisitById(id);

    try {
      final data = await client.from('visits').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return _mapVisitFromDb(data);
    } catch (_) {
      return _localFallback.getVisitById(id);
    }
  }

  @override
  Future<void> saveVisit(VisitSessionModel visit) async {
    await _localFallback.saveVisit(visit);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('visits').upsert({
        'id': visit.id,
        'folio': visit.folio,
        'branch_id': visit.branchId,
        'branch_name': visit.branchName,
        'auditor_id': visit.auditorId,
        'auditor_name': visit.auditorName,
        'branch_manager_name': visit.branchManagerName,
        'start_time': visit.startTime.toIso8601String(),
        'end_time': visit.endTime?.toIso8601String(),
        'is_completed': visit.isCompleted,
        'general_notes': visit.generalNotes,
        'groups': visit.groups.map((g) => g.toMap()).toList(),
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteVisit(String id) async {
    await _localFallback.deleteVisit(id);
    final client = _client;
    if (client == null) return;

    try {
      await client.from('visits').delete().eq('id', id);
    } catch (_) {}
  }

  @override
  Future<void> resetToSeedData() async {
    await _localFallback.resetToSeedData();
    final client = _client;
    if (client == null) return;

    try {
      // Sincronizar de vuelta a Supabase
      final users = await _localFallback.getUsers();
      for (final u in users) {
        await saveUser(u);
      }
      final branches = await _localFallback.getBranches();
      for (final b in branches) {
        await saveBranch(b);
      }
      final collabs = await _localFallback.getCollaborators();
      for (final c in collabs) {
        await saveCollaborator(c);
      }
      final stages = await _localFallback.getStages();
      for (final s in stages) {
        await saveStage(s);
      }
      final visits = await _localFallback.getVisits();
      for (final v in visits) {
        await saveVisit(v);
      }
    } catch (_) {}
  }

  // Mappers
  UserModel _mapUserFromDb(Map<String, dynamic> m) {
    return UserModel(
      id: m['id'] as String,
      name: m['name'] as String,
      email: m['email'] as String,
      role: m['role'] == 'admin' ? UserRole.admin : UserRole.rh,
      branchId: m['branch_id'] as String?,
      branchName: m['branch_name'] as String?,
      isActive: m['is_active'] as bool? ?? true,
    );
  }

  BranchModel _mapBranchFromDb(Map<String, dynamic> m) {
    return BranchModel(
      id: m['id'] as String,
      name: m['name'] as String,
      code: m['code'] as String,
      address: m['address'] as String? ?? '',
      city: m['city'] as String? ?? '',
      managerName: m['manager_name'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      isActive: m['is_active'] as bool? ?? true,
    );
  }

  CollaboratorModel _mapCollabFromDb(Map<String, dynamic> m) {
    return CollaboratorModel(
      id: m['id'] as String,
      code: m['code'] as String,
      fullName: m['full_name'] as String,
      branchId: m['branch_id'] as String,
      branchName: m['branch_name'] as String? ?? '',
      position: m['position'] as String? ?? 'Asesor de Calzado',
      isActive: m['is_active'] as bool? ?? true,
    );
  }

  StageModel _mapStageFromDb(Map<String, dynamic> m) {
    return StageModel(
      id: m['id'] as String,
      category: m['category'] == 'dobleG' ? StageCategory.dobleG : StageCategory.embudo,
      title: m['title'] as String,
      description: m['description'] as String? ?? '',
      orderIndex: m['order_index'] as int? ?? 0,
      isKeyConversion: m['is_key_conversion'] as bool? ?? false,
      targetSeconds: m['target_seconds'] as int?,
    );
  }

  VisitSessionModel _mapVisitFromDb(Map<String, dynamic> m) {
    return VisitSessionModel.fromMap({
      'id': m['id'],
      'folio': m['folio'],
      'branchId': m['branch_id'],
      'branchName': m['branch_name'],
      'auditorId': m['auditor_id'],
      'auditorName': m['auditor_name'],
      'branchManagerName': m['branch_manager_name'],
      'startTime': m['start_time'],
      'endTime': m['end_time'],
      'isCompleted': m['is_completed'],
      'generalNotes': m['general_notes'],
      'groups': m['groups'],
    });
  }
}
