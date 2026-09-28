import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/collaborator_model.dart';
import '../models/stage_model.dart';
import '../repositories/database_repository.dart';

class AdminProvider extends ChangeNotifier {
  final DatabaseRepository _repo;
  final Uuid _uuid = const Uuid();

  List<BranchModel> _branches = [];
  List<CollaboratorModel> _collaborators = [];
  List<StageModel> _stages = [];
  List<UserModel> _users = [];
  bool _isLoading = false;

  AdminProvider(this._repo) {
    loadAllData();
  }

  List<BranchModel> get branches => _branches;
  List<CollaboratorModel> get collaborators => _collaborators;
  List<StageModel> get stages => _stages;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    _branches = await _repo.getBranches();
    _collaborators = await _repo.getCollaborators();
    _stages = await _repo.getStages();
    _users = await _repo.getUsers();

    _isLoading = false;
    notifyListeners();
  }

  // Branch CRUD
  Future<void> saveBranch({
    String? id,
    required String name,
    required String code,
    required String address,
    required String city,
    required String managerName,
    required String phone,
    bool isActive = true,
  }) async {
    final branch = BranchModel(
      id: id ?? 'branch_${_uuid.v4().substring(0, 8)}',
      name: name,
      code: code,
      address: address,
      city: city,
      managerName: managerName,
      phone: phone,
      isActive: isActive,
    );
    await _repo.saveBranch(branch);
    await loadAllData();
  }

  Future<void> deleteBranch(String id) async {
    await _repo.deleteBranch(id);
    await loadAllData();
  }

  // Collaborator CRUD
  Future<void> saveCollaborator({
    String? id,
    required String code,
    required String fullName,
    required String branchId,
    required String branchName,
    required String position,
    bool isActive = true,
  }) async {
    final collaborator = CollaboratorModel(
      id: id ?? 'collab_${_uuid.v4().substring(0, 8)}',
      code: code,
      fullName: fullName,
      branchId: branchId,
      branchName: branchName,
      position: position,
      isActive: isActive,
    );
    await _repo.saveCollaborator(collaborator);
    await loadAllData();
  }

  Future<void> deleteCollaborator(String id) async {
    await _repo.deleteCollaborator(id);
    await loadAllData();
  }

  // Stage CRUD
  Future<void> saveStage({
    String? id,
    required StageCategory category,
    required String title,
    required String description,
    required int orderIndex,
    bool isKeyConversion = false,
    int? targetSeconds,
  }) async {
    final stage = StageModel(
      id: id ?? 'stage_${_uuid.v4().substring(0, 8)}',
      category: category,
      title: title,
      description: description,
      orderIndex: orderIndex,
      isKeyConversion: isKeyConversion,
      targetSeconds: targetSeconds,
    );
    await _repo.saveStage(stage);
    await loadAllData();
  }

  Future<void> deleteStage(String id) async {
    await _repo.deleteStage(id);
    await loadAllData();
  }

  // User CRUD
  Future<void> saveUser({
    String? id,
    required String name,
    required String email,
    required UserRole role,
    String? branchId,
    String? branchName,
    bool isActive = true,
  }) async {
    final user = UserModel(
      id: id ?? 'user_${_uuid.v4().substring(0, 8)}',
      name: name,
      email: email,
      role: role,
      branchId: branchId,
      branchName: branchName,
      isActive: isActive,
    );
    await _repo.saveUser(user);
    await loadAllData();
  }

  Future<void> deleteUser(String id) async {
    await _repo.deleteUser(id);
    await loadAllData();
  }

  Future<void> restoreDefaults() async {
    _isLoading = true;
    notifyListeners();
    await _repo.resetToSeedData();
    await loadAllData();
  }
}
