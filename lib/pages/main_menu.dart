import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/demo_store.dart';
import 'demo_panel.dart';

const menuItems = <({String title, IconData icon, String description})>[
  (
    title: 'Início',
    icon: Icons.home_outlined,
    description: 'Visão geral da demonstração.',
  ),
  (
    title: 'Clientes',
    icon: Icons.storefront_outlined,
    description: 'Cadastro e consulta de clientes e seus contatos.',
  ),
  (
    title: 'Usuários',
    icon: Icons.people_outline,
    description: 'Cadastro de usuários e definição dos perfis de acesso.',
  ),
  (
    title: 'Visitas',
    icon: Icons.event_outlined,
    description: 'Agenda, início e conclusão dos atendimentos.',
  ),
  (
    title: 'Importação',
    icon: Icons.upload_file_outlined,
    description: 'Importação do relatório de comissão para gravar os pedidos na tabela, sem cálculo de comissão.',
  ),
];

class MainMenu extends StatefulWidget {
  const MainMenu({super.key, this.demoStore});
  final DemoStore? demoStore;
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int selected = 0;
  late final Future<DemoStore> demo = widget.demoStore == null
      ? DemoStore.load()
      : Future.value(widget.demoStore!);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final wide = size.maxWidth >= 800;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Movisitas'),
          actions: [
            IconButton(
              tooltip: 'Sobre a demonstração',
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ambiente demonstrativo'),
                  content: const Text(
                    'Todos os dados são fictícios. Usuários, clientes, visitas e vendas são exemplos para apresentação. Não há conexão com banco de dados ou autenticação.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            if (wide)
              NavigationRail(
                extended: size.maxWidth >= 1100,
                backgroundColor: Colors.white,
                selectedIndex: selected,
                onDestinationSelected: (value) =>
                    setState(() => selected = value),
                labelType: size.maxWidth >= 1100
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  for (final item in menuItems)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.title),
                    ),
                ],
              ),
            Expanded(
              child: ListView(
                key: ValueKey(selected),
                padding: const EdgeInsets.all(24),
                children: [
                  const Wrap(
                    children: [
                      Chip(
                        avatar: Icon(Icons.science_outlined, size: 18),
                        label: Text('Demonstração • dados fictícios'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    menuItems[selected].title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  if (selected == 0) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF383838),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo ao Movisitas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Organize os clientes e acompanhe as visitas da equipe.',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Agenda de exemplo • 14/10/2026',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Roteiro demonstrativo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    for (final visit in demoVisits)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visit.time,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      visit.client,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(visit.city),
                                    const Text('Agendamento fictício'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Use o menu para consultar clientes, usuários, visitas e importar vendas fictícias.',
                    ),
                  ] else ...[
                    DemoPanel(section: selected, store: demo),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => setState(() => selected = 0),
                      child: const Text('Voltar ao início'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: (value) =>
                    setState(() => selected = value),
                destinations: [
                  for (final item in menuItems)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.title,
                    ),
                ],
              ),
      );
    },
  );
}
