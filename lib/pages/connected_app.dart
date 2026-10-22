import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_menu.dart';
import 'client_contact.dart';
import 'commercial_dashboard.dart';

typedef RowData = Map<String, dynamic>;
SupabaseClient get backend => Supabase.instance.client;

String errorMessage(Object error) {
  if (error is AuthException) {
    return 'Não foi possível entrar. Confira e-mail e senha.';
  }
  if (error is PostgrestException) {
    if (error.code == '23505') {
      return 'Código já cadastrado ou visita já em andamento. Confira os registros.';
    }
    if (error.code == '42501') {
      return 'Sua conta não tem permissão para esta operação.';
    }
    if (error.code == 'P0001') return error.message;
  }
  return 'Não foi possível concluir. Confira sua conexão e tente novamente.';
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: backend.auth.onAuthStateChange,
    builder: (context, snapshot) {
      final session = backend.auth.currentSession;
      return session == null
          ? const LoginPage()
          : ConnectedHome(key: ValueKey(session.user.id));
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await backend.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Movisitas',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ambiente acadêmico • utilize somente dados fictícios',
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => login(),
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy ? null : login,
                    child: Text(busy ? 'Entrando…' : 'Entrar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => const MainMenu()),
                    ),
                    child: const Text('Ver demonstração sem login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ConnectedHome extends StatefulWidget {
  const ConnectedHome({super.key});
  @override
  State<ConnectedHome> createState() => _ConnectedHomeState();
}

class _ConnectedHomeState extends State<ConnectedHome> {
  RowData? profile;
  List<RowData> clients = [], visits = [], users = [];
  bool loading = true, working = false;
  String? error;
  int selected = 0;
  bool get admin => profile?['role'] == 'administrator';
  final labels = ['Início', 'Clientes', 'Usuários', 'Visitas'];
  final icons = [
    Icons.home_outlined,
    Icons.storefront_outlined,
    Icons.people_outline,
    Icons.event_outlined,
  ];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final p = await backend
          .from('profiles')
          .select()
          .eq('id', backend.auth.currentUser!.id)
          .maybeSingle();
      if (p == null || p['active'] != true) {
        throw const FormatException(
          'Conta sem perfil ativo. Solicite a liberação ao administrador do projeto.',
        );
      }
      final results = await Future.wait([
        backend.from('clients').select().order('trade_name'),
        backend
            .from('app_visits')
            .select()
            .order('scheduled_at', ascending: false),
        backend
            .from('profiles')
            .select('id,full_name,role,active')
            .order('full_name'),
      ]);
      if (!mounted) return;
      setState(() {
        profile = p;
        clients = results[0];
        visits = results[1];
        users = results[2];
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is FormatException ? e.message : errorMessage(e),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String name(String id) =>
      clients.where((c) => c['id'] == id).firstOrNull?['trade_name']
          as String? ??
      'Cliente indisponível';
  String person(String? id) =>
      users.where((u) => u['id'] == id).firstOrNull?['full_name'] as String? ??
      'Sem responsável';
  String date(String? raw) {
    if (raw == null) return '—';
    final d = DateTime.parse(raw).toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> action(Future<void> Function() task) async {
    if (working) return;
    setState(() => working = true);
    try {
      await task();
      if (mounted) await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> clientForm([RowData? client]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ClientForm(client: client, users: users, admin: admin),
    );
    if (result == true && mounted) await load();
  }

  Future<void> newVisit(RowData client, bool start) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => VisitForm(client: client, start: start),
    );
    if (result == true && mounted) {
      setState(() => selected = 3);
      await load();
    }
  }

  Future<void> transition(RowData visit, String task) async {
    final notes = TextEditingController(text: visit['notes'] as String? ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${task == 'concluir'
              ? 'Concluir'
              : task == 'iniciar'
              ? 'Iniciar'
              : 'Cancelar'} visita?',
        ),
        content: task == 'concluir'
            ? TextField(
                controller: notes,
                maxLength: 2000,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Resumo do atendimento',
                ),
              )
            : Text(name(visit['client_id'] as String)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    final text = notes.text;
    notes.dispose();
    if (confirmed == true) {
      await action(() async {
        await backend.rpc(
          'transition_app_visit',
          params: {'p_id': visit['id'], 'p_action': task, 'p_notes': text},
        );
      });
    }
  }

  Widget clientCard(RowData c) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c['trade_name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ações de ${c['trade_name']}',
                enabled: !working,
                onSelected: (value) {
                  if (value == 'editar') {
                    clientForm(c);
                  } else {
                    newVisit(c, value == 'visitar');
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar cliente'),
                  ),
                  if (c['active'] == true)
                    const PopupMenuItem(
                      value: 'agendar',
                      child: Text('Agendar visita'),
                    ),
                  if (c['active'] == true)
                    const PopupMenuItem(
                      value: 'visitar',
                      child: Text('Fazer visita'),
                    ),
                ],
              ),
            ],
          ),
          Text(
            '${c['internal_code'] ?? 'Sem código'} • ${c['city']} • ${c['active'] == true ? 'Ativo' : 'Inativo'}',
          ),
          Text('Responsável: ${person(c['seller_id'] as String?)}'),
          ClientContact(
            name: c['contact_name'] as String? ?? '',
            phone: c['phone'] as String? ?? '',
          ),
          if ((c['email'] as String? ?? '').isNotEmpty)
            Text(c['email'] as String),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: working ? null : () => clientForm(c),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: working || c['active'] != true
                    ? null
                    : () => newVisit(c, true),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Fazer visita'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget visitCard(RowData v) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name(v['client_id'] as String),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${date(v['scheduled_at'] as String)} • ${switch (v['status']) {
              'em_andamento' => 'Em andamento',
              'concluida' => 'Concluída',
              'cancelada' => 'Cancelada',
              _ => 'Agendada',
            }}',
          ),
          Text('Responsável: ${person(v['seller_id'] as String)}'),
          if (v['started_at'] != null)
            Text('Início: ${date(v['started_at'] as String)}'),
          if (v['finished_at'] != null)
            Text('Conclusão: ${date(v['finished_at'] as String)}'),
          if ((v['notes'] as String).isNotEmpty) Text(v['notes'] as String),
          Wrap(
            spacing: 8,
            children: [
              if (v['status'] == 'agendada')
                TextButton(
                  onPressed: working ? null : () => transition(v, 'iniciar'),
                  child: const Text('Iniciar visita'),
                ),
              if (v['status'] == 'agendada')
                TextButton(
                  onPressed: working ? null : () => transition(v, 'cancelar'),
                  child: const Text('Cancelar agendamento'),
                ),
              if (v['status'] == 'em_andamento')
                FilledButton(
                  onPressed: working ? null : () => transition(v, 'concluir'),
                  child: const Text('Concluir visita'),
                ),
            ],
          ),
        ],
      ),
    ),
  );
  List<Widget> content() {
    if (selected == 1) {
      return [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: working ? null : () => clientForm(),
            icon: const Icon(Icons.add),
            label: const Text('Novo cliente'),
          ),
        ),
        const SizedBox(height: 12),
        if (clients.isEmpty)
          const Text('Nenhum cliente cadastrado para esta conta.'),
        ...clients.map(clientCard),
      ];
    }
    if (selected == 2) {
      return [
        Text(
          admin
              ? 'Equipe cadastrada no ambiente acadêmico'
              : 'Seu perfil de acesso',
        ),
        ...users.map(
          (u) => Card(
            child: ListTile(
              title: Text(u['full_name'] as String),
              subtitle: Text(
                '${u['role'] == 'administrator'
                    ? 'Administrador'
                    : u['role'] == 'seller'
                    ? 'Vendedor'
                    : 'Gerente'} • ${u['active'] == true ? 'Ativo' : 'Inativo'}',
              ),
            ),
          ),
        ),
        const Text(
          'Contas de acesso são provisionadas pelo administrador do projeto. Nenhuma senha é exibida nesta tela.',
        ),
      ];
    }
    if (selected == 3) {
      return [
        const Text('Agende ou inicie uma visita pelas ações de um cliente.'),
        if (visits.isEmpty) const Text('Nenhuma visita registrada.'),
        ...visits.map(visitCard),
      ];
    }
    return [
      CommercialDashboard(
        clients: clients,
        visits: visits,
        users: users,
        name: profile?['full_name'] as String? ?? '',
        admin: admin,
        openClients: () => setState(() => selected = 1),
        openVisits: () => setState(() => selected = 3),
        visitCard: visitCard,
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const MainMenu()),
        ),
        child: const Text('Abrir demonstração de importação de vendas'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) => Scaffold(
      appBar: AppBar(
        title: const Text('Movisitas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: loading || working ? null : load,
            icon: const Icon(Icons.refresh),
          ),
          TextButton(
            onPressed: () async {
              try {
                await backend.auth.signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(errorMessage(e))));
                }
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
      body: Row(
        children: [
          if (size.maxWidth >= 800)
            NavigationRail(
              selectedIndex: selected,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => setState(() => selected = i),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(icons[i]),
                    label: Text(labels[i]),
                  ),
              ],
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(error!),
                          TextButton(
                            onPressed: load,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text('Ambiente acadêmico • dados fictícios'),
                      const SizedBox(height: 12),
                      Text(
                        labels[selected],
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ...content(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: size.maxWidth >= 800
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (i) => setState(() => selected = i),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
              ],
            ),
    ),
  );
}

class ClientForm extends StatefulWidget {
  const ClientForm({
    super.key,
    this.client,
    required this.users,
    required this.admin,
  });
  final RowData? client;
  final List<RowData> users;
  final bool admin;
  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  static const labels = {
    'trade_name': 'Nome fantasia *',
    'legal_name': 'Razão social',
    'internal_code': 'Código interno',
    'contact_name': 'Pessoa de contato',
    'email': 'E-mail',
    'phone': 'Telefone / WhatsApp (com DDD)',
    'street': 'Rua',
    'street_number': 'Número',
    'district': 'Bairro',
    'city': 'Cidade *',
    'state': 'UF',
    'postal_code': 'CEP',
    'notes': 'Observações',
  };
  String? seller;
  bool active = true, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    for (final key in labels.keys) {
      fields[key] = TextEditingController(
        text: widget.client?[key] as String? ?? '',
      );
    }
    seller =
        widget.client?['seller_id'] as String? ?? backend.auth.currentUser!.id;
    active = widget.client?['active'] as bool? ?? true;
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    final values = <String, dynamic>{
      for (final e in fields.entries)
        e.key: e.value.text.trim().isEmpty ? null : e.value.text.trim(),
      'seller_id': seller,
      'active': active,
    };
    try {
      if (widget.client == null) {
        await backend.from('clients').insert(values).select('id').single();
      } else {
        await backend
            .from('clients')
            .update(values)
            .eq('id', widget.client!['id'])
            .select('id')
            .single();
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.client == null ? 'Novo cliente' : 'Editar cliente'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Preencha somente informações fictícias para a apresentação.',
                ),
                for (final e in labels.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      controller: fields[e.key],
                      enabled: !busy,
                      maxLength: e.key == 'notes' ? 2000 : 200,
                      maxLines: e.key == 'notes' ? 3 : 1,
                      decoration: InputDecoration(
                        labelText: e.value,
                        counterText: '',
                      ),
                      validator: (raw) {
                        final s = raw?.trim() ?? '';
                        if ((e.key == 'trade_name' || e.key == 'city') &&
                            s.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (e.key == 'state' &&
                            s.isNotEmpty &&
                            !RegExp(r'^[A-Z]{2}$').hasMatch(s)) {
                          return 'Informe duas letras maiúsculas';
                        }
                        if (e.key == 'email' &&
                            s.isNotEmpty &&
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(s)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                if (widget.admin)
                  DropdownButtonFormField<String>(
                    initialValue: seller,
                    decoration: const InputDecoration(labelText: 'Responsável'),
                    items: [
                      for (final u in widget.users)
                        DropdownMenuItem(
                          value: u['id'] as String,
                          child: Text(u['full_name'] as String),
                        ),
                    ],
                    onChanged: busy ? null : (v) => setState(() => seller = v),
                  ),
                SwitchListTile(
                  title: const Text('Cliente ativo'),
                  value: active,
                  onChanged: busy ? null : (v) => setState(() => active = v),
                ),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Salvando…' : 'Salvar cliente'),
        ),
      ],
    ),
  );
}

class VisitForm extends StatefulWidget {
  const VisitForm({super.key, required this.client, required this.start});
  final RowData client;
  final bool start;
  @override
  State<VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends State<VisitForm> {
  final notes = TextEditingController();
  DateTime when = DateTime.now().add(const Duration(hours: 1));
  bool busy = false;
  String? error;
  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Future<void> choose() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: when,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(when),
    );
    if (time != null && mounted) {
      setState(
        () => when = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> save() async {
    if (busy) return;
    if (!widget.start && !when.isAfter(DateTime.now())) {
      setState(() => error = 'Escolha uma data futura.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await backend.rpc(
        'create_app_visit',
        params: {
          'p_client': widget.client['id'],
          'p_when': when.toUtc().toIso8601String(),
          'p_start': widget.start,
          'p_notes': notes.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.start ? 'Fazer visita' : 'Agendar visita'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.client['trade_name'] as String),
            const SizedBox(height: 12),
            Text('O atendimento será registrado no seu usuário.'),
            if (!widget.start)
              TextButton(
                onPressed: busy ? null : choose,
                child: Text(
                  '${when.day}/${when.month}/${when.year} ${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')} • Alterar',
                ),
              ),
            TextField(
              controller: notes,
              enabled: !busy,
              maxLength: 2000,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Observações'),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(
            busy
                ? 'Salvando…'
                : widget.start
                ? 'Iniciar visita'
                : 'Salvar agendamento',
          ),
        ),
      ],
    ),
  );
}
