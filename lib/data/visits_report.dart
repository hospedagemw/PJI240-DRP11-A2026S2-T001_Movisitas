import 'dart:convert';

typedef ReportRow = Map<String, dynamic>;
const visitStatusLabels = {
  'agendada': 'Agendada',
  'em_andamento': 'Em andamento',
  'concluida': 'Concluída',
  'cancelada': 'Cancelada',
};
String reportDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String reportTime(dynamic raw) {
  final date = DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
  return date == null
      ? '—'
      : '${reportDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String buildVisitsHtml({
  required List<ReportRow> visits,
  required List<ReportRow> clients,
  required List<ReportRow> users,
  required String periodLabel,
  required String statusLabel,
  required String teamLabel,
  required DateTime generatedAt,
}) {
  String esc(Object? value) =>
      const HtmlEscape().convert(value?.toString() ?? '');
  final clientNames = {for (final c in clients) c['id']: c['trade_name']};
  final userNames = {for (final u in users) u['id']: u['full_name']};
  final summary = visitStatusLabels.entries
      .map(
        (s) =>
            '<div class="metric"><strong>${visits.where((v) => v['status'] == s.key).length}</strong>${esc(s.value)}</div>',
      )
      .join();
  final rows = visits
      .map(
        (v) =>
            '<tr><td>${esc(clientNames[v['client_id']] ?? 'Cliente indisponível')}</td><td>${esc(userNames[v['seller_id']] ?? 'Responsável indisponível')}</td><td>${esc(visitStatusLabels[v['status']] ?? v['status'])}</td><td>${esc(reportTime(v['scheduled_at']))}</td><td>${esc(reportTime(v['started_at']))}</td><td>${esc(reportTime(v['finished_at']))}</td><td class="notes">${esc(v['notes'])}</td></tr>',
      )
      .join();
  return '''<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Movisitas — Relatório de visitas</title><style>
*{box-sizing:border-box}body{margin:0;background:#f5f5f7;color:#333;font:15px/1.5 Arial,sans-serif}main{max-width:1450px;margin:32px auto;padding:32px;background:white;border-top:6px solid #ed3237}h1{font-size:28px;margin:0 0 4px}h2{font-size:19px}.brand{color:#c52b30;font-weight:bold;letter-spacing:2px}.muted{color:#666}.filters{display:flex;flex-wrap:wrap;gap:12px 36px;margin:24px 0}.metrics{display:flex;flex-wrap:wrap;gap:12px}.metric{background:#f4f4f6;padding:14px 22px;min-width:145px}.metric strong{display:block;font-size:26px}table{border-collapse:collapse;width:100%;font-size:13px}th,td{border:1px solid #ddd;padding:10px;text-align:left;vertical-align:top;overflow-wrap:anywhere}th{background:#383838;color:white}tbody tr:nth-child(even){background:#fafafa}.notes{white-space:pre-wrap;min-width:170px}.table-wrap{overflow:auto}footer{margin-top:24px;color:#666;font-size:12px}@media print{@page{size:A4 landscape;margin:12mm}body{background:white}main{margin:0;padding:0;max-width:none}table{font-size:10px}th{background:#eee;color:#000}thead{display:table-header-group}.table-wrap{overflow:visible}.metric{padding:7px 14px}h1{font-size:22px}}
</style></head><body><main><p class="brand">MOVISITAS</p><h1>Relatório de visitas</h1><p class="muted">Ambiente acadêmico • Dados fictícios</p><div class="filters"><div><b>Período</b><br>${esc(periodLabel)}</div><div><b>Status</b><br>${esc(statusLabel)}</div><div><b>Equipe ou responsável</b><br>${esc(teamLabel)}</div></div><p class="muted">Filtro de período aplicado à data agendada da visita. Datas apresentadas no horário local da geração.</p><div class="metrics"><div class="metric"><strong>${visits.length}</strong>Total de visitas</div>$summary</div><h2>Detalhamento dos atendimentos</h2>${visits.isEmpty ? '<p>Nenhuma visita encontrada para os filtros selecionados.</p>' : '<div class="table-wrap"><table><thead><tr><th>Cliente</th><th>Responsável</th><th>Status</th><th>Agendamento</th><th>Início</th><th>Conclusão</th><th>Observações</th></tr></thead><tbody>$rows</tbody></table></div>'}<footer>Gerado em ${esc(reportTime(generatedAt.toIso8601String()))}. Este arquivo representa os registros disponíveis no momento da exportação. Para imprimir ou salvar em PDF, utilize a função de impressão do navegador.</footer></main></body></html>''';
}
