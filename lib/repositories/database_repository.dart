import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/collaborator_model.dart';
import '../models/stage_model.dart';
import '../models/visit_session_model.dart';

abstract class DatabaseRepository {
  // Users
  Future<List<UserModel>> getUsers();
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser(String id);

  // Branches
  Future<List<BranchModel>> getBranches();
  Future<void> saveBranch(BranchModel branch);
  Future<void> deleteBranch(String id);

  // Collaborators
  Future<List<CollaboratorModel>> getCollaborators({String? branchId});
  Future<void> saveCollaborator(CollaboratorModel collaborator);
  Future<void> deleteCollaborator(String id);

  // Stages (Doble G & Embudo)
  Future<List<StageModel>> getStages();
  Future<void> saveStage(StageModel stage);
  Future<void> deleteStage(String id);

  // Visits
  Future<List<VisitSessionModel>> getVisits();
  Future<VisitSessionModel?> getVisitById(String id);
  Future<void> saveVisit(VisitSessionModel visit);
  Future<void> deleteVisit(String id);

  // Reset to seed data
  Future<void> resetToSeedData();
}
