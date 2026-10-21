import 'dart:convert';

import 'package:flutter/services.dart';

import 'order_html_parser.dart';

class DemoStore {
  DemoStore(this.data) {
    imported.addAll(orders.take(6).map((o) => o['id'] as String));
  }
  final Map<String, dynamic> data;
  final Set<String> imported = {};
  List<Map<String, dynamic>> rows(String key) =>
      (data[key] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get clients => rows('clients');
  List<Map<String, dynamic>> get users => rows('users');
  List<Map<String, dynamic>> get visits => rows('visits');
  List<Map<String, dynamic>> get orders => rows('orders');
  String clientName(String id) =>
      clients.singleWhere((c) => c['id'] == id)['name'] as String;
  String userName(String id) =>
      users.singleWhere((u) => u['id'] == id)['name'] as String;
  static Future<DemoStore> load() async => DemoStore(
    jsonDecode(await rootBundle.loadString('assets/demo.json'))
        as Map<String, dynamic>,
  );

  // Apenas o conjunto fictício conhecido é aceito nesta demonstração pública.
  // Nenhum HTML é executado ou inserido na interface.
  ({int added, int duplicates}) importHtml(String html) {
    if (html.length > 200000) {
      throw const FormatException('Arquivo excede o limite de 200 KB.');
    }
    final parsed = const OrderHtmlParser().parse(html);
    if (parsed.length != orders.length) {
      throw const FormatException(
        'Utilize o HTML fictício fornecido, com os 18 pedidos completos.',
      );
    }
    final accepted = <String>{};
    for (final row in parsed) {
      final match = orders.where((o) => o['id'] == row.sourceTitle).toList();
      if (match.length != 1) {
        throw const FormatException('Pedido fora do conjunto fictício.');
      }
      final o = match.single;
      final c = clients.singleWhere((c) => c['id'] == o['client']);
      if (row.internalCode != c['code'] ||
          row.clientName != c['name'] ||
          row.issuedAt != DateTime.parse(o['date'] as String) ||
          (row.baseValue * 100 - (o['cents'] as int)).abs() > 0.001 ||
          !accepted.add(row.sourceTitle)) {
        throw const FormatException(
          'Conteúdo diferente do exemplo fictício. Baixe novamente o HTML.',
        );
      }
    }
    final added = accepted.difference(imported).length;
    imported.addAll(accepted);
    return (added: added, duplicates: accepted.length - added);
  }
}

String demoMoney(int cents) {
  final integer = (cents ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $integer,${(cents % 100).toString().padLeft(2, '0')}';
}
