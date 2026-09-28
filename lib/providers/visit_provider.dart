import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/branch_model.dart';
import '../models/collaborator_model.dart';
import '../models/stage_model.dart';
import '../models/group_interaction_model.dart';
import '../models/visit_session_model.dart';
import '../repositories/database_repository.dart';

class VisitProvider extends ChangeNotifier {
  final DatabaseRepository _repo;
  final Uuid _uuid = const Uuid();

  List<VisitSessionModel> _visits = [];
  VisitSessionModel? _currentVisit;
  VisitSessionModel? _viewingVisit; // Para ver visitas pasadas
  List<StageModel> _stages = [];
  List<CollaboratorModel> _branchCollaborators = [];
  int _activeGroupIndex = 0;
  bool _isLoading = false;

  Timer? _tickerTimer;
  DateTime _nowTicker = DateTime.now();

  VisitProvider(this._repo) {
    _init();
  }

  List<VisitSessionModel> get visits => _visits;
  VisitSessionModel? get currentVisit => _currentVisit;
  VisitSessionModel? get viewingVisit => _viewingVisit ?? _currentVisit;
  List<StageModel> get stages => _stages;
  List<CollaboratorModel> get branchCollaborators => _branchCollaborators;
  int get activeGroupIndex => _activeGroupIndex;
  bool get isLoading => _isLoading;
  DateTime get nowTicker => _nowTicker;

  bool get hasActiveVisit => _currentVisit != null && !_currentVisit!.isCompleted;

  GroupInteractionModel? get currentGroup {
    if (_currentVisit == null || _currentVisit!.groups.isEmpty) return null;
    if (_activeGroupIndex >= 0 && _activeGroupIndex < _currentVisit!.groups.length) {
      return _currentVisit!.groups[_activeGroupIndex];
    }
    return _currentVisit!.groups.first;
  }

  Future<void> _init() async {
    _stages = await _repo.getStages();
    await loadVisits();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _nowTicker = DateTime.now();
      notifyListeners();
    });
  }

  void _stopTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  Future<void> loadVisits() async {
    _isLoading = true;
    notifyListeners();
    _visits = await _repo.getVisits();
    _stages = await _repo.getStages();
    _isLoading = false;
    notifyListeners();
  }

  void setViewingVisit(VisitSessionModel visit) {
    _viewingVisit = visit;
    notifyListeners();
  }

  // Iniciar una nueva visita de auditoría RH
  Future<void> startNewVisit({
    required BranchModel branch,
    required String auditorId,
    required String auditorName,
    required String branchManagerName,
  }) async {
    _isLoading = true;
    notifyListeners();

    _stages = await _repo.getStages();
    _branchCollaborators = await _repo.getCollaborators(branchId: branch.id);

    // Si la sucursal no tiene colaboradores asignados, traer todos los colaboradores disponibles
    if (_branchCollaborators.isEmpty) {
      _branchCollaborators = await _repo.getCollaborators();
    }

    final now = DateTime.now();
    final randomSuffix = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
    final folio = 'LGZ-VIS-${DateFormat('yyyyMMdd').format(now)}-$randomSuffix';

    // Crear el primer grupo inicial (Grupo A #1)
    final initialGroup = _createInitialGroup(
      visitId: 'visit_${_uuid.v4().substring(0, 8)}',
      letter: 'A',
      number: 1,
      now: now,
    );

    _currentVisit = VisitSessionModel(
      id: initialGroup.visitId,
      folio: folio,
      branchId: branch.id,
      branchName: branch.name,
      auditorId: auditorId,
      auditorName: auditorName,
      branchManagerName: branchManagerName.isEmpty ? branch.managerName : branchManagerName,
      startTime: now,
      groups: [initialGroup],
    );

    _activeGroupIndex = 0;
    _startTicker();
    await _repo.saveVisit(_currentVisit!);
    await loadVisits();
    _isLoading = false;
    notifyListeners();
  }

  GroupInteractionModel _createInitialGroup({
    required String visitId,
    required String letter,
    required int number,
    required DateTime now,
  }) {
    final defaultCollab = _branchCollaborators.isNotEmpty
        ? _branchCollaborators.first
        : CollaboratorModel(
            id: 'collab_default',
            code: 'V1',
            fullName: 'Asesor de Turno',
            branchId: '',
            branchName: '',
          );

    final initialStages = <String, StageResultState>{};
    for (final s in _stages) {
      initialStages[s.id] = StageResultState.unobserved;
    }

    return GroupInteractionModel(
      id: 'grp_${_uuid.v4().substring(0, 8)}',
      visitId: visitId,
      groupLetter: letter,
      groupNumber: number,
      arrivalTime: now,
      startTrackingTime: now,
      peopleCount: 1,
      collaboratorId: defaultCollab.id,
      collaboratorCode: defaultCollab.code,
      collaboratorName: defaultCollab.fullName,
      segment: 'Damas',
      zone: 'A',
      stageResults: initialStages,
    );
  }

  // Agregar nuevo grupo de clientes concurrentes o consecutivos
  void addNewGroup() {
    if (_currentVisit == null) return;

    final now = DateTime.now();
    final nextNumber = _currentVisit!.groups.length + 1;
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final nextLetter = letters[(nextNumber - 1) % letters.length];

    final newGroup = _createInitialGroup(
      visitId: _currentVisit!.id,
      letter: nextLetter,
      number: nextNumber,
      now: now,
    );

    _currentVisit!.groups.add(newGroup);
    _activeGroupIndex = _currentVisit!.groups.length - 1;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  void selectGroup(int index) {
    if (_currentVisit == null) return;
    if (index >= 0 && index < _currentVisit!.groups.length) {
      _activeGroupIndex = index;
      notifyListeners();
    }
  }

  // Ajuste rápido de hora de llegada (-1m, -2m)
  void adjustArrivalTime(int minutesDelta) {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final adjusted = group.arrivalTime.add(Duration(minutes: minutesDelta));
    // No permitir que la llegada sea en el futuro
    if (adjusted.isBefore(DateTime.now())) {
      final updatedGroup = group.copyWith(arrivalTime: adjusted);
      _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
      _repo.saveVisit(_currentVisit!);
      notifyListeners();
    }
  }

  // Registrar momento exacto de la 1ª Atención
  void markFirstAttention() {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final updatedGroup = group.copyWith(firstAttentionTime: DateTime.now());
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Cambiar número de personas (1, 2, 3+)
  void updatePeopleCount(int count) {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final updatedGroup = group.copyWith(peopleCount: count);
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Asignar colaborador / vendedor
  void updateCollaborator(CollaboratorModel collaborator) {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final updatedGroup = group.copyWith(
      collaboratorId: collaborator.id,
      collaboratorCode: collaborator.code,
      collaboratorName: collaborator.fullName,
    );
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Cambiar segmento (Damas, Caballeros, Niños, etc.)
  void updateSegment(String segment) {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final updatedGroup = group.copyWith(segment: segment);
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Cambiar zona de piso (A, B, C)
  void updateZone(String zone) {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final updatedGroup = group.copyWith(zone: zone);
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Ciclo interactivo de etapa: Sin observar -> Sí -> No -> Sin observar
  void cycleStage(String stageId) {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final currentStageState = group.stageResults[stageId] ?? StageResultState.unobserved;
    final nextState = currentStageState.next;

    final updatedResults = Map<String, StageResultState>.from(group.stageResults);
    updatedResults[stageId] = nextState;

    final updatedGroup = group.copyWith(stageResults: updatedResults);
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Finalizar grupo actual
  void finalizeCurrentGroup() {
    final group = currentGroup;
    if (group == null || group.isCompleted) return;

    final now = DateTime.now();
    final updatedGroup = group.copyWith(
      isCompleted: true,
      completedTime: now,
      firstAttentionTime: group.firstAttentionTime ?? now,
    );
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Marcar incidencia / abandono
  void reportIncident(String note) {
    final group = currentGroup;
    if (group == null) return;

    final updatedGroup = group.copyWith(
      hasIncident: true,
      incidentNote: note,
    );
    _currentVisit!.groups[_activeGroupIndex] = updatedGroup;
    _repo.saveVisit(_currentVisit!);
    notifyListeners();
  }

  // Finalizar la visita completa
  Future<void> completeVisit(String notes) async {
    if (_currentVisit == null) return;

    _stopTicker();
    // Finalizar cualquier grupo que haya quedado abierto
    final completedGroups = _currentVisit!.groups.map((g) {
      if (!g.isCompleted) {
        return g.copyWith(
          isCompleted: true,
          completedTime: DateTime.now(),
          firstAttentionTime: g.firstAttentionTime ?? DateTime.now(),
        );
      }
      return g;
    }).toList();

    _currentVisit = _currentVisit!.copyWith(
      isCompleted: true,
      endTime: DateTime.now(),
      generalNotes: notes,
      groups: completedGroups,
    );

    await _repo.saveVisit(_currentVisit!);
    _viewingVisit = _currentVisit;
    await loadVisits();
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
