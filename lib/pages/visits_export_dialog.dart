import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/visits_report.dart';
import '../data/report_download.dart';

class VisitsExportDialog extends StatefulWidget {
  const VisitsExportDialog({
    super.key,
    required this.admin,
    required this.users,
    required this.initialSeller,
    this.initialRange,
  });
  final bool admin;
  final List<ReportRow> users;
  final String initialSeller;
  final DateTimeRange? initialRange;
  @override
  State<VisitsExportDialog> createState() => _VisitsExportDialogState();
}

class _VisitsExportDialogState extends State<VisitsExportDialog> {
  late DateTimeRange? range = widget.initialRange;
  late String seller =
      widget.admin && widget.users.any((u) => u['id'] == widget.initialSeller)
      ? widget.initialSeller
      : 'all';
  String status = 'all';
  bool busy = false;
  String? error;
  Future<List<ReportRow>> loadNames(
    String table,
    Set<String> ids,
    String fields,
  ) async {
    final result = <ReportRow>[];
    final list = ids.toList();
    for (var i = 0; i < list.length; i += 200) {
      result.addAll(
        await Supabase.instance.client
            .from(table)
            .select(fields)
            .inFilter('id', list.sublist(i, (i + 200).clamp(0, list.length))),
      );
    }
    return result;
  }

  Future<void> export() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final db = Supabase.instance.client;
      final uid = db.auth.currentUser?.id;
      if (uid == null) throw StateError('Entre novamente para exportar.');
      final profile = await db
          .from('profiles')
          .select('role,active,full_name')
          .eq('id', uid)
          .single();
      if (profile['active'] != true) {
        throw StateError('Sua conta não está ativa.');
      }
      final isAdmin = profile['role'] == 'administrator';
      if (!isAdmin && profile['role'] != 'seller') {
        throw StateError('Seu perfil não permite exportar visitas.');
      }
      final rows = <ReportRow>[];
      for (var offset = 0; ; offset += 1000) {
        var query = db
            .from('app_visits')
            .select(
              'id,client_id,seller_id,status,scheduled_at,started_at,finished_at,notes',
            );
        if (!isAdmin) {
          query = query.eq('seller_id', uid);
        } else if (seller != 'all') {
          query = query.eq('seller_id', seller);
        }
        if (status != 'all') query = query.eq('status', status);
        if (range != null) {
          final begin = DateTime(
            range!.start.year,
            range!.start.month,
            range!.start.day,
          );
          final end = DateTime(
            range!.end.year,
            range!.end.month,
            range!.end.day + 1,
          );
          query = query
              .gte('scheduled_at', begin.toUtc().toIso8601String())
              .lt('scheduled_at', end.toUtc().toIso8601String());
        }
        final page = await query
            .order('scheduled_at')
            .order('id')
            .range(offset, offset + 999);
        rows.addAll(page);
        if (page.length < 1000) break;
      }
      final names = await Future.wait([
        loadNames(
          'clients',
          rows.map((v) => v['client_id'] as String).toSet(),
          'id,trade_name',
        ),
        loadNames(
          'profiles',
          rows.map((v) => v['seller_id'] as String).toSet(),
          'id,full_name',
        ),
      ]);
      final label = !isAdmin
          ? '${profile['full_name']} — minhas visitas'
          : seller == 'all'
          ? 'Toda a equipe'
          : widget.users
                        .where((u) => u['id'] == seller)
                        .firstOrNull?['full_name']
                    as String? ??
                'Responsável selecionado';
      final now = DateTime.now();
      final html = buildVisitsHtml(
        visits: rows,
        clients: names[0],
        users: names[1],
        periodLabel: range == null
            ? 'Todo o histórico'
            : '${reportDate(range!.start)} a ${reportDate(range!.end)}',
        statusLabel: visitStatusLabels[status] ?? 'Todos os status',
        teamLabel: label,
        generatedAt: now,
      );
      downloadReport(
        html,
        'movisitas-visitas-${now.millisecondsSinceEpoch}.html',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Download solicitado: ${rows.length} visita(s). Confira os downloads do navegador.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is StateError ? e.message.toString() : 'Não foi possível exportar. Confira a conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Exportar visitas em HTML'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'O período considera a data agendada da visita, incluindo o primeiro e o último dia.',
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('Todos os status'),
                  ),
                  for (final entry in visitStatusLabels.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: busy ? null : (v) => setState(() => status = v!),
              ),
              const SizedBox(height: 16),
              if (widget.admin)
                DropdownButtonFormField<String>(
                  initialValue: seller,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Equipe ou responsável',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Toda a equipe'),
                    ),
                    for (final user in widget.users)
                      DropdownMenuItem(
                        value: user['id'] as String,
                        child: Text(user['full_name'] as String),
                      ),
                  ],
                  onChanged: busy ? null : (v) => setState(() => seller = v!),
                )
              else
                const Text('Escopo: somente minhas visitas.'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100, 12, 31),
                          initialDateRange: range,
                          helpText: 'Período do relatório',
                          saveText: 'Aplicar',
                        );
                        if (picked != null && mounted) {
                          setState(() => range = picked);
                        }
                      },
                icon: const Icon(Icons.date_range),
                label: Text(
                  range == null
                      ? 'Selecionar período'
                      : '${reportDate(range!.start)} a ${reportDate(range!.end)}',
                ),
              ),
              TextButton(
                onPressed: busy ? null : () => setState(() => range = null),
                child: const Text('Usar todo o histórico'),
              ),
              const Text(
                'O arquivo poderá ser aberto e impresso no navegador. Os dados serão consultados novamente no Supabase.',
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: busy ? null : export,
          icon: const Icon(Icons.download),
          label: Text(busy ? 'Gerando relatório…' : 'Baixar HTML'),
        ),
      ],
    ),
  );
}
