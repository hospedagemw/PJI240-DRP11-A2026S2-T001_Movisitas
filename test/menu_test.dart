import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movisitas/pages/main_menu.dart';
import 'package:movisitas/data/demo_store.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets('Menu navega em largura $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = DemoStore(
        jsonDecode(File('assets/demo.json').readAsStringSync())
            as Map<String, dynamic>,
      );
      await tester.pumpWidget(MaterialApp(home: MainMenu(demoStore: store)));
      expect(find.text('Mercado Horizonte'), findsOneWidget);
      expect(
        find.byType(width < 800 ? NavigationBar : NavigationRail),
        findsOneWidget,
      );
      for (final label in ['Clientes', 'Usuários', 'Visitas', 'Importação']) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(find.text(label), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Voltar ao início'),
          500,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('Voltar ao início'));
        await tester.pumpAndSettle();
        expect(find.text('Mercado Horizonte'), findsOneWidget);
      }
    });
  }
}
