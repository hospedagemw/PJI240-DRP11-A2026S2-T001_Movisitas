import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:movisitas/data/visits_report.dart';
import 'package:movisitas/pages/visits_export_dialog.dart';

void main() {
  test('Agrupamento separa IDs mesmo com nomes iguais e conta os status', () {
    final html = buildVisitsHtml(
      visits: [
        {'seller_id': 'a', 'status': 'agendada', 'notes': 'REGISTRO_A'},
        {'seller_id': 'b', 'status': 'concluida', 'notes': 'REGISTRO_B'},
        {'seller_id': 'a', 'status': 'concluida', 'notes': 'REGISTRO_C'},
      ],
      clients: [],
      users: [{'id': 'a', 'full_name': 'Nome <igual>'}, {'id': 'b', 'full_name': 'Nome <igual>'}],
      periodLabel: 'Tudo', statusLabel: 'Todos', teamLabel: 'Equipe',
      generatedAt: DateTime(2026), grouping: 'seller_status',
    );
    expect(html, contains('Nome &lt;igual&gt; — 2 visita(s)'));
    expect(html, contains('Nome &lt;igual&gt; — 1 visita(s)'));
    expect(html, contains('Agendada — 1 visita(s)'));
    expect(RegExp('REGISTRO_[ABC]').allMatches(html).length, 3);
    expect(html.indexOf('REGISTRO_C'), lessThan(html.indexOf('REGISTRO_B')));
  });

  test('HTML escapa conteúdo e mantém observações como texto', () {
    final html = buildVisitsHtml(
      visits: [
        {
          'client_id': 'c',
          'seller_id': 'u',
          'status': 'concluida',
          'scheduled_at': '2026-10-26T12:00:00Z',
          'notes': '<script>alert(1)</script> & teste',
        },
      ],
      clients: [
        {'id': 'c', 'trade_name': 'Loja <Exemplo>'},
      ],
      users: [
        {'id': 'u', 'full_name': 'Ana & Bruno'},
      ],
      periodLabel: 'Outubro',
      statusLabel: 'Concluída',
      teamLabel: 'Equipe',
      generatedAt: DateTime(2026, 10, 26),
    );
    expect(html, contains('&lt;script&gt;'));
    expect(html, isNot(contains('<script>')));
    expect(html, contains('Loja &lt;Exemplo&gt;'));
    expect(html, contains('Ana &amp; Bruno'));
    expect(html, contains('<strong>1</strong>Total de visitas'));
  });
  test('Relatório vazio informa filtros e ausência de resultados', () {
    final html = buildVisitsHtml(
      visits: [],
      clients: [],
      users: [],
      periodLabel: '01/10/2026 a 31/10/2026',
      statusLabel: 'Agendada',
      teamLabel: 'Minhas visitas',
      generatedAt: DateTime(2026, 10, 26),
    );
    expect(html, contains('Nenhuma visita encontrada'));
    expect(html, contains('Minhas visitas'));
    expect(html, contains('01&#47;10&#47;2026 a 31&#47;10&#47;2026'));
  });
  testWidgets('Vendedor não recebe seletor de equipe', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisitsExportDialog(
            admin: false,
            users: [],
            initialSeller: 'all',
          ),
        ),
      ),
    );
    expect(find.text('Escopo: somente minhas visitas.'), findsOneWidget);
    expect(find.text('Equipe ou responsável'), findsNothing);
    expect(find.text('Baixar HTML'), findsOneWidget);
  });
}
