import 'package:flutter/material.dart';

import 'visits_export_dialog.dart';

typedef DashboardRow = Map<String, dynamic>;

class CommercialDashboard extends StatefulWidget {
  const CommercialDashboard({
    super.key,
    required this.clients,
    required this.visits,
    required this.users,
    required this.name,
    required this.admin,
    required this.openClients,
    required this.openVisits,
    required this.visitCard,
  });
  final List<DashboardRow> clients, visits, users;
  final String name;
  final bool admin;
  final VoidCallback openClients, openVisits;
  final Widget Function(DashboardRow) visitCard;
  @override
  State<CommercialDashboard> createState() => _CommercialDashboardState();
}

class _CommercialDashboardState extends State<CommercialDashboard> {
  String period = 'month', seller = 'all';
  static const red = Color(0xFFED3237);
  static const ink = Color(0xFF383838);
  void exportVisits() {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final start = switch (period) {
      'today' => day,
      'week' => DateTime(now.year, now.month, now.day - now.weekday + 1),
      'month' => DateTime(now.year, now.month),
      _ => null,
    };
    final end = switch (period) {
      'today' => day,
      'week' => DateTime(start!.year, start.month, start.day + 6),
      'month' => DateTime(now.year, now.month + 1, 0),
      _ => null,
    };
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VisitsExportDialog(
        admin: widget.admin,
        users: widget.users,
        initialSeller: seller,
        initialRange: start == null
            ? null
            : DateTimeRange(start: start, end: end!),
      ),
    );
  }

  static const states = {
    'agendada': 'Agendadas',
    'em_andamento': 'Em andamento',
    'concluida': 'Concluídas',
    'cancelada': 'Canceladas',
  };
  static const colors = [
    Color(0xFFDA941D),
    Color(0xFF4474C5),
    Color(0xFF16836E),
    Color(0xFF858590),
  ];

  void showRecords(String label, List<DashboardRow> records, bool isClient) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label (${records.length})'),
        content: SizedBox(
          width: 640,
          height: MediaQuery.sizeOf(ctx).height * .55,
          child: records.isEmpty
              ? const Center(
                  child: Text('Nenhum registro para os filtros selecionados.'),
                )
              : ListView.separated(
                  itemCount: records.length,
                  separatorBuilder: (_, index) => const Divider(),
                  itemBuilder: (_, index) {
                    final row = records[index];
                    final client = isClient
                        ? row
                        : widget.clients
                              .where((c) => c['id'] == row['client_id'])
                              .firstOrNull;
                    final date = DateTime.tryParse(
                      row['scheduled_at'] as String? ?? '',
                    )?.toLocal();
                    return ListTile(
                      leading: Icon(
                        isClient
                            ? Icons.storefront_outlined
                            : Icons.event_outlined,
                        color: red,
                      ),
                      title: Text(
                        client?['trade_name'] as String? ??
                            'Cliente indisponível',
                      ),
                      subtitle: Text(
                        isClient
                            ? '${row['city'] ?? ''}\nContato: ${row['contact_name'] ?? 'Não informado'}'
                            : '${date == null ? 'Sem data' : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'} • ${states[row['status']] ?? ''}\n${row['notes'] ?? ''}',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              isClient ? widget.openClients() : widget.openVisits();
            },
            child: Text(isClient ? 'Gerenciar clientes' : 'Gerenciar visitas'),
          ),
        ],
      ),
    );
  }

  Widget metric(Widget child, String label, VoidCallback onTap) => Semantics(
    button: true,
    label: 'Consultar $label',
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(padding: const EdgeInsets.all(22), child: child),
      ),
    ),
  );

  bool inPeriod(DashboardRow v) {
    final raw = v['status'] == 'concluida'
        ? v['finished_at']
        : v['status'] == 'em_andamento'
        ? v['started_at']
        : v['scheduled_at'];
    final date = DateTime.tryParse(raw as String? ?? '')?.toLocal();
    if (date == null) return false;
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final start = switch (period) {
      'today' => day,
      'week' => day.subtract(Duration(days: now.weekday - 1)),
      'month' => DateTime(now.year, now.month),
      _ => null,
    };
    final end = switch (period) {
      'today' => day.add(const Duration(days: 1)),
      'week' => start!.add(const Duration(days: 7)),
      'month' => DateTime(now.year, now.month + 1),
      _ => null,
    };
    return (start == null || !date.isBefore(start)) &&
        (end == null || date.isBefore(end));
  }

  Widget panel(Widget child) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8E8EE)),
    ),
    child: child,
  );

  Widget title(String text, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF707079), fontSize: 13),
      ),
      const SizedBox(height: 22),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final rows = widget.visits
        .where(
          (v) => inPeriod(v) && (seller == 'all' || v['seller_id'] == seller),
        )
        .toList();
    final clients = widget.clients
        .where((c) => seller == 'all' || c['seller_id'] == seller)
        .toList();
    final counts = [
      for (final s in states.keys) rows.where((v) => v['status'] == s).length,
    ];
    final pending =
        widget.visits
            .where(
              (v) =>
                  (v['status'] == 'agendada' ||
                      v['status'] == 'em_andamento') &&
                  (seller == 'all' || v['seller_id'] == seller),
            )
            .toList()
          ..sort(
            (a, b) => (a['scheduled_at'] as String).compareTo(
              b['scheduled_at'] as String,
            ),
          );
    final total = rows.length;
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF383838), Color(0xFF222229)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MOVISITAS  /  VISÃO COMERCIAL',
                style: TextStyle(
                  color: Color(0xFFFF9B9E),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Olá, ${widget.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Sua carteira e seus atendimentos em um só lugar.  •  ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                style: const TextStyle(color: Color(0xFFD4D4DA), height: 1.6),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: widget.openClients,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Nova visita'),
                    style: FilledButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.openClients,
                    icon: const Icon(Icons.people_outline),
                    label: const Text('Ver clientes'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<String>(
                initialValue: period,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Período das visitas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'today', child: Text('Hoje')),
                  DropdownMenuItem(value: 'week', child: Text('Esta semana')),
                  DropdownMenuItem(value: 'month', child: Text('Este mês')),
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('Todo o histórico'),
                  ),
                ],
                onChanged: (v) => setState(() => period = v!),
              ),
            ),
            if (widget.admin)
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: seller,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Responsável',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Toda a equipe'),
                    ),
                    for (final u in widget.users)
                      DropdownMenuItem(
                        value: u['id'] as String,
                        child: Text(u['full_name'] as String),
                      ),
                  ],
                  onChanged: (v) => setState(() => seller = v!),
                ),
              ),
            OutlinedButton.icon(
              onPressed: exportVisits,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Exportar visitas'),
            ),
            const Text(
              'Dados atualizados do Supabase',
              style: TextStyle(fontSize: 12, color: Color(0xFF707079)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, size) {
            final columns = size.maxWidth >= 900
                ? 4
                : size.maxWidth >= 460
                ? 2
                : 1;
            final values = [clients.length, counts[0], counts[1], counts[2]];
            final labels = [
              'Clientes na carteira',
              'Visitas agendadas',
              'Em andamento',
              'Visitas concluídas',
            ];
            final icons = [
              Icons.storefront_outlined,
              Icons.event_outlined,
              Icons.near_me_outlined,
              Icons.task_alt,
            ];
            final tones = [red, colors[0], colors[1], colors[2]];
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (var i = 0; i < 4; i++)
                  SizedBox(
                    width: (size.maxWidth - (columns - 1) * 14) / columns,
                    child: metric(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${values[i]}',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: tones[i].withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icons[i], color: tones[i]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            labels[i],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            i == 0
                                ? 'Carteira completa'
                                : 'No período selecionado',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF707079),
                            ),
                          ),
                        ],
                      ),
                      labels[i],
                      () => showRecords(
                        labels[i],
                        i == 0
                            ? clients
                            : rows
                                  .where(
                                    (v) =>
                                        v['status'] ==
                                        [
                                          'agendada',
                                          'em_andamento',
                                          'concluida',
                                        ][i - 1],
                                  )
                                  .toList(),
                        i == 0,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, size) {
            final summary = panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(
                    'Panorama das visitas',
                    '$total atendimento(s) no período',
                  ),
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors[i],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(states.values.elementAt(i))),
                              Text(
                                '${counts[i]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          LinearProgressIndicator(
                            value: total == 0 ? 0 : counts[i] / total,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(8),
                            color: colors[i],
                            backgroundColor: const Color(0xFFF1F1F5),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    total == 0
                        ? 'Nenhuma visita neste período.'
                        : '${(counts[2] / total * 100).round()}% das visitas do período concluídas.',
                    style: const TextStyle(
                      color: Color(0xFF707079),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
            final team = panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(
                    widget.admin
                        ? 'Atendimentos por responsável'
                        : 'Seu acompanhamento',
                    'Concluídas / total no período',
                  ),
                  for (final u in widget.users.where(
                    (u) => seller == 'all' || u['id'] == seller,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFF4F4F8),
                            foregroundColor: ink,
                            child: Text(
                              (u['full_name'] as String).substring(0, 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              u['full_name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${rows.where((v) => v['seller_id'] == u['id'] && v['status'] == 'concluida').length} / ${rows.where((v) => v['seller_id'] == u['id']).length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 26),
                  TextButton.icon(
                    onPressed: widget.openVisits,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Ver histórico de visitas'),
                  ),
                ],
              ),
            );
            return size.maxWidth < 800
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [summary, const SizedBox(height: 18), team],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 18),
                      Expanded(child: team),
                    ],
                  );
          },
        ),
        const SizedBox(height: 26),
        title(
          'Próximos atendimentos',
          'Pendências de todo o histórico • filtro por responsável',
        ),
        if (pending.isEmpty)
          panel(
            Column(
              children: [
                const Icon(
                  Icons.event_available_outlined,
                  size: 36,
                  color: Color(0xFF16836E),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tudo em dia por aqui',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const SizedBox(height: 6),
                const Text('Nenhuma visita pendente para este responsável.'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.openClients,
                  child: const Text('Escolher cliente para uma nova visita'),
                ),
              ],
            ),
          ),
        ...pending.take(6).map(widget.visitCard),
      ],
    );
  }
}
