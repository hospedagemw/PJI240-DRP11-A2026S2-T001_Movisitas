import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movisitas/data/demo_store.dart';

void main() {
  final html = File('assets/vendas-ficticias.html').readAsStringSync();
  DemoStore fixture() => DemoStore(
    jsonDecode(File('assets/demo.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  test(
    'HTML compatível com parser original; importação repetida não duplica',
    () {
      final s = fixture();
      expect(s.importHtml(html), (added: 12, duplicates: 6));
      expect(s.imported.length, 18);
      expect(s.importHtml(html), (added: 0, duplicates: 18));
      expect(
        s.orders.fold<int>(0, (sum, o) => sum + (o['cents'] as int)),
        4350825,
      );
      expect(demoMoney(4350825), 'R\$ 43.508,25');
    },
  );
  test('Rejeita arquivo alterado ou incompleto sem importar parcialmente', () {
    final s = fixture();
    for (final invalid in [
      html.replaceFirst('900001', '999999'),
      html.replaceFirst('1.250,50', '1.250,51'),
      html.replaceFirst('Mercado Horizonte', 'Cliente real'),
      html.replaceFirst('01/10/2026', '31/02/2026'),
      '<html></html>',
      'x' * 200001,
    ]) {
      expect(() => s.importHtml(invalid), throwsFormatException);
      expect(s.imported.length, 6);
    }
  });
  test('Referências e e-mails pertencem ao conjunto fictício', () {
    final s = fixture();
    expect(s.users.length, 5);
    expect(s.clients.length, 6);
    expect(s.visits.length, 12);
    for (final c in s.clients) {
      expect(s.userName(c['seller'] as String), isNotEmpty);
      expect(c['email'], endsWith('@example.com'));
    }
    for (final v in s.visits) {
      expect(s.clientName(v['client'] as String), isNotEmpty);
      expect(s.userName(v['user'] as String), isNotEmpty);
    }
  });
}
