import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movisitas/app.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets('Menu navega em largura $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MovisitasApp());
      expect(find.text('Mercado Horizonte'), findsOneWidget);
      expect(
        find.byType(width < 800 ? NavigationBar : NavigationRail),
        findsOneWidget,
      );
      for (final label in ['Clientes', 'Usuários', 'Visitas', 'Importação']) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Implementação prevista para a próxima etapa deste módulo.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Voltar ao início'));
        await tester.pumpAndSettle();
        expect(find.text('Mercado Horizonte'), findsOneWidget);
      }
    });
  }
}
