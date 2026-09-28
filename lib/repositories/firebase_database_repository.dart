import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/collaborator_model.dart';
import '../models/stage_model.dart';
import '../models/visit_session_model.dart';
import 'database_repository.dart';

/// Implementación para Firebase Cloud Firestore.
/// En cuanto proporciones las credenciales de Firebase (google-services.json o configuración FirebaseOptions),
/// esta clase conectará directamente con las colecciones:
/// - `users`
/// - `branches`
/// - `collaborators`
/// - `stages`
/// - `visits`
class FirebaseDatabaseRepository implements DatabaseRepository {
  // Para activar Firebase, descomentar las llamadas de FirebaseFirestore.instance:
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getUsers() async {
    // Ejemplo de implementación con Cloud Firestore:
    // final snapshot = await _firestore.collection('users').get();
    // return snapshot.docs.map((d) => UserModel.fromMap(d.data())).toList();
    throw UnimplementedError('Firebase en espera de configuración. Utilizando repositorio local.');
  }

  @override
  Future<void> saveUser(UserModel user) async {
    // await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  @override
  Future<void> deleteUser(String id) async {
    // await _firestore.collection('users').doc(id).delete();
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    throw UnimplementedError('Firebase en espera de configuración.');
  }

  @override
  Future<void> saveBranch(BranchModel branch) async {
    // await _firestore.collection('branches').doc(branch.id).set(branch.toMap());
  }

  @override
  Future<void> deleteBranch(String id) async {
    // await _firestore.collection('branches').doc(id).delete();
  }

  @override
  Future<List<CollaboratorModel>> getCollaborators({String? branchId}) async {
    throw UnimplementedError('Firebase en espera de configuración.');
  }

  @override
  Future<void> saveCollaborator(CollaboratorModel collaborator) async {
    // await _firestore.collection('collaborators').doc(collaborator.id).set(collaborator.toMap());
  }

  @override
  Future<void> deleteCollaborator(String id) async {
    // await _firestore.collection('collaborators').doc(id).delete();
  }

  @override
  Future<List<StageModel>> getStages() async {
    throw UnimplementedError('Firebase en espera de configuración.');
  }

  @override
  Future<void> saveStage(StageModel stage) async {
    // await _firestore.collection('stages').doc(stage.id).set(stage.toMap());
  }

  @override
  Future<void> deleteStage(String id) async {
    // await _firestore.collection('stages').doc(id).delete();
  }

  @override
  Future<List<VisitSessionModel>> getVisits() async {
    throw UnimplementedError('Firebase en espera de configuración.');
  }

  @override
  Future<VisitSessionModel?> getVisitById(String id) async {
    throw UnimplementedError('Firebase en espera de configuración.');
  }

  @override
  Future<void> saveVisit(VisitSessionModel visit) async {
    // await _firestore.collection('visits').doc(visit.id).set(visit.toMap());
  }

  @override
  Future<void> deleteVisit(String id) async {
    // await _firestore.collection('visits').doc(id).delete();
  }

  @override
  Future<void> resetToSeedData() async {}
}
