import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rh_manage_control/models/stage_model.dart';
import 'package:rh_manage_control/models/group_interaction_model.dart';
import 'package:rh_manage_control/models/visit_session_model.dart';
import 'package:rh_manage_control/widgets/brand_logo.dart';

void main() {
  testWidgets('BrandLogo renders subtitle and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandLogo(fontSize: 24),
        ),
      ),
    );

    expect(find.text('Z A P A T E R Í A'), findsOneWidget);
    expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
  });

  test('Collaborator conversion rate calculates correctly', () {
    final now = DateTime.now();
    final stages = [
      StageModel(
        id: 's_atencion',
        category: StageCategory.embudo,
        title: 'Atención',
        description: 'Saludo',
        orderIndex: 1,
      ),
      StageModel(
        id: 's_compra',
        category: StageCategory.embudo,
        title: 'Compra',
        description: 'Venta',
        orderIndex: 2,
        isKeyConversion: true,
      ),
    ];

    // Colaborador V1 con 2 clientes atendidos, 1 compra concretada = 50% conversión
    final groups = [
      GroupInteractionModel(
        id: 'g1',
        visitId: 'v1',
        groupLetter: 'A',
        groupNumber: 1,
        arrivalTime: now,
        startTrackingTime: now,
        firstAttentionTime: now.add(const Duration(seconds: 8)),
        peopleCount: 1,
        collaboratorId: 'c1',
        collaboratorCode: 'V1',
        collaboratorName: 'Carlos Mendoza',
        stageResults: {
          's_atencion': StageResultState.yes,
          's_compra': StageResultState.yes,
        },
        isCompleted: true,
      ),
      GroupInteractionModel(
        id: 'g2',
        visitId: 'v1',
        groupLetter: 'B',
        groupNumber: 2,
        arrivalTime: now,
        startTrackingTime: now,
        firstAttentionTime: now.add(const Duration(seconds: 12)),
        peopleCount: 2,
        collaboratorId: 'c1',
        collaboratorCode: 'V1',
        collaboratorName: 'Carlos Mendoza',
        stageResults: {
          's_atencion': StageResultState.yes,
          's_compra': StageResultState.no,
        },
        isCompleted: true,
      ),
    ];

    final visit = VisitSessionModel(
      id: 'v1',
      folio: 'LGZ-TEST-01',
      branchId: 'b1',
      branchName: 'Sucursal Centro',
      auditorId: 'u1',
      auditorName: 'Carolina Ruiz',
      branchManagerName: 'Carlos Ramón',
      startTime: now,
      groups: groups,
    );

    final stats = visit.calculateCollaboratorStats(stages);
    expect(stats.length, 1);
    expect(stats.first.attendedCount, 2);
    expect(stats.first.boughtCount, 1);
    expect(stats.first.conversionRate, 50.0);
    expect(stats.first.avgResponseTimeSeconds, 10.0);
    expect(visit.overallConversionRate(stages), 50.0);
  });
}
