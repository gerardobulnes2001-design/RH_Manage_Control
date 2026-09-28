import 'group_interaction_model.dart';
import 'stage_model.dart';

class CollaboratorAuditStats {
  final String collaboratorId;
  final String collaboratorCode;
  final String collaboratorName;
  final int attendedCount;
  final int boughtCount;
  final double conversionRate; // (boughtCount / attendedCount) * 100
  final double avgResponseTimeSeconds;
  final double dobleGCompliance; // % of Yes in Doble G
  final double embudoCompliance; // % of Yes in Embudo
  final int totalPeopleServed;

  CollaboratorAuditStats({
    required this.collaboratorId,
    required this.collaboratorCode,
    required this.collaboratorName,
    required this.attendedCount,
    required this.boughtCount,
    required this.conversionRate,
    required this.avgResponseTimeSeconds,
    required this.dobleGCompliance,
    required this.embudoCompliance,
    required this.totalPeopleServed,
  });
}

class VisitSessionModel {
  final String id;
  final String folio; // e.g. "LGZ-VIS-2026-0042"
  final String branchId;
  final String branchName;
  final String auditorId;
  final String auditorName;
  final String branchManagerName;
  final DateTime startTime;
  DateTime? endTime;
  bool isCompleted;
  String generalNotes;
  List<GroupInteractionModel> groups;

  VisitSessionModel({
    required this.id,
    required this.folio,
    required this.branchId,
    required this.branchName,
    required this.auditorId,
    required this.auditorName,
    required this.branchManagerName,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.generalNotes = '',
    required this.groups,
  });

  // Cálculo de estadísticas consolidadas por colaborador
  List<CollaboratorAuditStats> calculateCollaboratorStats(List<StageModel> allStages) {
    final Map<String, List<GroupInteractionModel>> groupsByCollab = {};

    for (final group in groups) {
      if (!group.isCompleted) continue; // Solo considerar grupos finalizados
      groupsByCollab.putIfAbsent(group.collaboratorId, () => []).add(group);
    }

    final List<CollaboratorAuditStats> statsList = [];

    groupsByCollab.forEach((collabId, collabGroups) {
      if (collabGroups.isEmpty) return;

      final firstGroup = collabGroups.first;
      final totalAttended = collabGroups.length;
      int boughtCount = 0;
      int totalPeople = 0;
      double totalResponseTime = 0;
      int responseTimeCount = 0;

      int dobleGTotal = 0;
      int dobleGYes = 0;
      int embudoTotal = 0;
      int embudoYes = 0;

      for (final grp in collabGroups) {
        totalPeople += grp.peopleCount;

        if (grp.isPurchaseMade(allStages)) {
          boughtCount++;
        }

        if (grp.firstAttentionTime != null) {
          totalResponseTime += grp.secondsToFirstAttention;
          responseTimeCount++;
        }

        for (final stage in allStages) {
          final res = grp.stageResults[stage.id];
          if (res != null && res != StageResultState.unobserved) {
            if (stage.category == StageCategory.dobleG) {
              dobleGTotal++;
              if (res == StageResultState.yes) dobleGYes++;
            } else {
              embudoTotal++;
              if (res == StageResultState.yes) embudoYes++;
            }
          }
        }
      }

      final conversionRate = totalAttended > 0 ? (boughtCount / totalAttended) * 100 : 0.0;
      final avgResponse = responseTimeCount > 0 ? (totalResponseTime / responseTimeCount) : 0.0;
      final dobleGComp = dobleGTotal > 0 ? (dobleGYes / dobleGTotal) * 100 : 0.0;
      final embudoComp = embudoTotal > 0 ? (embudoYes / embudoTotal) * 100 : 0.0;

      statsList.add(
        CollaboratorAuditStats(
          collaboratorId: collabId,
          collaboratorCode: firstGroup.collaboratorCode,
          collaboratorName: firstGroup.collaboratorName,
          attendedCount: totalAttended,
          boughtCount: boughtCount,
          conversionRate: conversionRate,
          avgResponseTimeSeconds: avgResponse,
          dobleGCompliance: dobleGComp,
          embudoCompliance: embudoComp,
          totalPeopleServed: totalPeople,
        ),
      );
    });

    // Ordenar por tasa de conversión descendente
    statsList.sort((a, b) => b.conversionRate.compareTo(a.conversionRate));
    return statsList;
  }

  // Tasa de conversión global de la visita
  double overallConversionRate(List<StageModel> allStages) {
    final completed = groups.where((g) => g.isCompleted).toList();
    if (completed.isEmpty) return 0.0;
    final purchases = completed.where((g) => g.isPurchaseMade(allStages)).length;
    return (purchases / completed.length) * 100;
  }

  VisitSessionModel copyWith({
    String? id,
    String? folio,
    String? branchId,
    String? branchName,
    String? auditorId,
    String? auditorName,
    String? branchManagerName,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? generalNotes,
    List<GroupInteractionModel>? groups,
  }) {
    return VisitSessionModel(
      id: id ?? this.id,
      folio: folio ?? this.folio,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      auditorId: auditorId ?? this.auditorId,
      auditorName: auditorName ?? this.auditorName,
      branchManagerName: branchManagerName ?? this.branchManagerName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      generalNotes: generalNotes ?? this.generalNotes,
      groups: groups ?? List.from(this.groups),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folio': folio,
      'branchId': branchId,
      'branchName': branchName,
      'auditorId': auditorId,
      'auditorName': auditorName,
      'branchManagerName': branchManagerName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'generalNotes': generalNotes,
      'groups': groups.map((g) => g.toMap()).toList(),
    };
  }

  factory VisitSessionModel.fromMap(Map<String, dynamic> map) {
    final groupsRaw = (map['groups'] as List<dynamic>? ?? [])
        .map((g) => GroupInteractionModel.fromMap(g as Map<String, dynamic>))
        .toList();

    return VisitSessionModel(
      id: map['id'] as String,
      folio: map['folio'] as String,
      branchId: map['branchId'] as String,
      branchName: map['branchName'] as String? ?? '',
      auditorId: map['auditorId'] as String,
      auditorName: map['auditorName'] as String? ?? '',
      branchManagerName: map['branchManagerName'] as String? ?? '',
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      generalNotes: map['generalNotes'] as String? ?? '',
      groups: groupsRaw,
    );
  }
}
