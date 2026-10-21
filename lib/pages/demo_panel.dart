import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_store.dart';
import '../data/demo_file.dart';

class DemoPanel extends StatefulWidget {
  const DemoPanel({super.key, required this.section, required this.store});
  final int section;
  final Future<DemoStore> store;
  @override
  State<DemoPanel> createState() => _DemoPanelState();
}

class _DemoPanelState extends State<DemoPanel> {
  String message = '';
  Future<void> import(DemoStore store, bool sample) async {
    try {
      final html = sample
          ? await rootBundle.loadString('assets/vendas-ficticias.html')
          : await pickDemoHtml();
      if (html == null || !mounted) return;
      final result = store.importHtml(html);
      setState(
        () => message =
            '${result.added} pedidos importados; ${result.duplicates} já existentes.',
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => message = error is FormatException
              ? error.message
              : 'Não foi possível ler o HTML. Tente novamente.',
        );
      }
    }
  }

  Widget card(String title, String details, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFED3237)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(details),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<DemoStore>(
    future: widget.store,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text(
          'Não foi possível carregar os exemplos. Recarregue a página.',
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final s = snapshot.data!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.section == 1) ...[
            const Text('6 clientes fictícios • carteira demonstrativa'),
            for (final c in s.clients)
              card(
                c['name'] as String,
                '${c['code']} • ${c['city']}\n${c['email']}\nResponsável: ${s.userName(c['seller'] as String)}',
                Icons.storefront_outlined,
              ),
          ],
          if (widget.section == 2) ...[
            const Text(
              '5 personagens fictícios. Estes registros não possuem login nem senha.',
            ),
            for (final u in s.users)
              card(
                u['name'] as String,
                '${u['role']} • ${u['id']}\n${u['email']}',
                Icons.person_outline,
              ),
          ],
          if (widget.section == 3) ...[
            const Text('12 visitas fictícias • outubro de 2026'),
            for (final v in s.visits)
              card(
                s.clientName(v['client'] as String),
                '${(v['date'] as String).split('-').reversed.join('/')} • ${v['time']} • ${v['status']}\n${s.userName(v['user'] as String)}\n${v['notes']}',
                Icons.event_outlined,
              ),
          ],
          if (widget.section == 4) ...[
            const Text(
              'Importe o relatório fictício para incluir pedidos na demonstração. Não há cálculo de comissão.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: downloadDemoHtml,
                  icon: const Icon(Icons.download),
                  label: const Text('Baixar HTML fictício'),
                ),
                FilledButton.icon(
                  onPressed: () => import(s, false),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Selecionar HTML'),
                ),
                TextButton(
                  onPressed: () => import(s, true),
                  child: const Text('Importar exemplo incluído'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'A importação desta tela fica apenas na sessão do navegador. Ao recarregar, voltam os 6 pedidos iniciais. O banco contém uma cópia independente dos 18 exemplos, sem sincronização com esta tela.',
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${s.imported.length} pedidos • Total: ${demoMoney(s.orders.where((o) => s.imported.contains(o['id'])).fold<int>(0, (total, o) => total + (o['cents'] as int)))}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final o in s.orders.where((o) => s.imported.contains(o['id'])))
              card(
                '${o['id']} • ${s.clientName(o['client'] as String)}',
                '${(o['date'] as String).split('-').reversed.join('/')} • ${demoMoney(o['cents'] as int)}',
                Icons.receipt_long_outlined,
              ),
          ],
        ],
      );
    },
  );
}
