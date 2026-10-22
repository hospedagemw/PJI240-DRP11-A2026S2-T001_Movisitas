import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movisitas/pages/commercial_dashboard.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets('Painel responsivo e filtro de período em $width', (tester) async {
      tester.view.physicalSize = Size(width, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
        child: CommercialDashboard(clients: const [], visits: const [
          {'id': 'old', 'seller_id': 'seller', 'status': 'concluida', 'finished_at': '2020-01-01T12:00:00Z', 'scheduled_at': '2020-01-01T12:00:00Z'}
        ], users: const [{'id':'seller','full_name':'Vendedor Exemplo'}], name:'Exemplo',admin:false,
        openClients:(){},openVisits:(){},visitCard:(_)=>const SizedBox()),
      ))));
      expect(find.text('0 atendimento(s) no período'), findsOneWidget);
      expect(find.text('Responsável'), findsNothing);
      await tester.tap(find.text('Este mês'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todo o histórico').last);
      await tester.pumpAndSettle();
      expect(find.text('1 atendimento(s) no período'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
