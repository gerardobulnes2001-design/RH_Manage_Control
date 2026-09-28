import 'stage_model.dart';

class GroupInteractionModel {
  final String id;
  final String visitId;
  final String groupLetter; // "A", "B", "C", etc.
  final int groupNumber;     // 1, 2, 3...
  final DateTime arrivalTime;
  final DateTime startTrackingTime;
  DateTime? firstAttentionTime;
  int peopleCount;           // 1, 2, 3 (3 represents 3+)
  String collaboratorId;
  String collaboratorCode;   // "V1"
  String collaboratorName;
  String segment;            // "Damas", "Caballeros", "Niños", "Deportivo", "Confort"
  String zone;               // "A", "B", "C"
  Map<String, StageResultState> stageResults; // stageId -> state
  DateTime? completedTime;
  bool isCompleted;
  bool hasIncident;
  String? incidentNote;

  GroupInteractionModel({
    required this.id,
    required this.visitId,
    required this.groupLetter,
    required this.groupNumber,
    required this.arrivalTime,
    required this.startTrackingTime,
    this.firstAttentionTime,
    this.peopleCount = 1,
    required this.collaboratorId,
    required this.collaboratorCode,
    required this.collaboratorName,
    this.segment = 'Damas',
    this.zone = 'A',
    required this.stageResults,
    this.completedTime,
    this.isCompleted = false,
    this.hasIncident = false,
    this.incidentNote,
  });

  String get displayName => '$groupLetter Grupo #$groupNumber';

  // Verifica si el cliente compró (buscando si alguna etapa de tipo Compra se marcó como 'yes')
  bool isPurchaseMade(List<StageModel> allStages) {
    for (final stage in allStages) {
      if (stage.isKeyConversion || stage.title.toLowerCase().contains('compra')) {
        if (stageResults[stage.id] == StageResultState.yes) {
          return true;
        }
      }
    }
    return false;
  }

  // Tiempo hasta primera atención en segundos
  int get secondsToFirstAttention {
    if (firstAttentionTime == null) return 0;
    return firstAttentionTime!.difference(arrivalTime).inSeconds;
  }

  // Duración total de la atención
  int get totalDurationSeconds {
    final end = completedTime ?? DateTime.now();
    return end.difference(arrivalTime).inSeconds;
  }

  GroupInteractionModel copyWith({
    String? id,
    String? visitId,
    String? groupLetter,
    int? groupNumber,
    DateTime? arrivalTime,
    DateTime? startTrackingTime,
    DateTime? firstAttentionTime,
    int? peopleCount,
    String? collaboratorId,
    String? collaboratorCode,
    String? collaboratorName,
    String? segment,
    String? zone,
    Map<String, StageResultState>? stageResults,
    DateTime? completedTime,
    bool? isCompleted,
    bool? hasIncident,
    String? incidentNote,
  }) {
    return GroupInteractionModel(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      groupLetter: groupLetter ?? this.groupLetter,
      groupNumber: groupNumber ?? this.groupNumber,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      startTrackingTime: startTrackingTime ?? this.startTrackingTime,
      firstAttentionTime: firstAttentionTime ?? this.firstAttentionTime,
      peopleCount: peopleCount ?? this.peopleCount,
      collaboratorId: collaboratorId ?? this.collaboratorId,
      collaboratorCode: collaboratorCode ?? this.collaboratorCode,
      collaboratorName: collaboratorName ?? this.collaboratorName,
      segment: segment ?? this.segment,
      zone: zone ?? this.zone,
      stageResults: stageResults ?? Map.from(this.stageResults),
      completedTime: completedTime ?? this.completedTime,
      isCompleted: isCompleted ?? this.isCompleted,
      hasIncident: hasIncident ?? this.hasIncident,
      incidentNote: incidentNote ?? this.incidentNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visitId': visitId,
      'groupLetter': groupLetter,
      'groupNumber': groupNumber,
      'arrivalTime': arrivalTime.toIso8601String(),
      'startTrackingTime': startTrackingTime.toIso8601String(),
      'firstAttentionTime': firstAttentionTime?.toIso8601String(),
      'peopleCount': peopleCount,
      'collaboratorId': collaboratorId,
      'collaboratorCode': collaboratorCode,
      'collaboratorName': collaboratorName,
      'segment': segment,
      'zone': zone,
      'stageResults': stageResults.map((k, v) => MapEntry(k, v.name)),
      'completedTime': completedTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'hasIncident': hasIncident,
      'incidentNote': incidentNote,
    };
  }

  factory GroupInteractionModel.fromMap(Map<String, dynamic> map) {
    final stagesRaw = map['stageResults'] as Map<String, dynamic>? ?? {};
    final stagesParsed = stagesRaw.map((k, v) {
      StageResultState state = StageResultState.unobserved;
      if (v == 'yes') state = StageResultState.yes;
      if (v == 'no') state = StageResultState.no;
      return MapEntry(k, state);
    });

    return GroupInteractionModel(
      id: map['id'] as String,
      visitId: map['visitId'] as String,
      groupLetter: map['groupLetter'] as String? ?? 'A',
      groupNumber: map['groupNumber'] as int? ?? 1,
      arrivalTime: DateTime.parse(map['arrivalTime'] as String),
      startTrackingTime: DateTime.parse(map['startTrackingTime'] as String),
      firstAttentionTime: map['firstAttentionTime'] != null
          ? DateTime.parse(map['firstAttentionTime'] as String)
          : null,
      peopleCount: map['peopleCount'] as int? ?? 1,
      collaboratorId: map['collaboratorId'] as String,
      collaboratorCode: map['collaboratorCode'] as String? ?? 'V1',
      collaboratorName: map['collaboratorName'] as String? ?? '',
      segment: map['segment'] as String? ?? 'Damas',
      zone: map['zone'] as String? ?? 'A',
      stageResults: stagesParsed,
      completedTime: map['completedTime'] != null
          ? DateTime.parse(map['completedTime'] as String)
          : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      hasIncident: map['hasIncident'] as bool? ?? false,
      incidentNote: map['incidentNote'] as String?,
    );
  }
}
