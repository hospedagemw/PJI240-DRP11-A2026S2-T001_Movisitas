import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key, this.user, required this.ownAccount});
  final Map<String, dynamic>? user;
  final bool ownAccount;
  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(
    text: widget.user?['full_name'] as String? ?? '',
  );
  final email = TextEditingController();
  final password = TextEditingController();
  late String role = widget.user?['role'] as String? ?? 'seller';
  bool busy = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final db = Supabase.instance.client;
      if (widget.user == null) {
        await db.functions.invoke(
          'admin-users',
          body: {
            'name': name.text.trim(),
            'email': email.text.trim(),
            'password': password.text,
            'role': role,
          },
        );
      } else {
        await db.rpc(
          'admin_update_profile',
          params: {
            'p_id': widget.user!['id'],
            'p_name': name.text.trim(),
            'p_role': role,
            'p_active': widget.user!['active'],
          },
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is PostgrestException && e.code == 'P0001'
              ? e.message
              : e is FunctionException && e.details is Map
              ? (e.details as Map)['message'] as String? ??
                    'Não foi possível cadastrar o usuário.'
              : 'Não foi possível salvar. Confira sua conexão e tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.user == null ? 'Novo usuário' : 'Editar usuário'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  enabled: !busy,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  validator: (v) => (v ?? '').trim().length < 2
                      ? 'Informe o nome completo'
                      : null,
                ),
                if (widget.user == null) ...[
                  TextFormField(
                    controller: email,
                    enabled: !busy,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 254,
                    decoration: const InputDecoration(
                      labelText: 'E-mail de acesso',
                    ),
                    validator: (v) =>
                        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch((v ?? '').trim())
                        ? 'Informe um e-mail válido'
                        : null,
                  ),
                  TextFormField(
                    controller: password,
                    enabled: !busy,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Senha inicial',
                      helperText: 'De 8 a 128 caracteres',
                    ),
                    validator: (v) =>
                        (v ?? '').length < 8 || (v ?? '').length > 128
                        ? 'Use de 8 a 128 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: [
                    const DropdownMenuItem(
                      value: 'seller',
                      child: Text('Vendedor'),
                    ),
                    const DropdownMenuItem(
                      value: 'administrator',
                      child: Text('Administrador'),
                    ),
                    if (role == 'manager')
                      const DropdownMenuItem(
                        value: 'manager',
                        child: Text('Gerente'),
                      ),
                  ],
                  onChanged: busy || widget.ownAccount
                      ? null
                      : (v) => setState(() => role = v!),
                ),
                if (widget.ownAccount)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Seu acesso administrativo será mantido.'),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
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
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Salvando…' : 'Salvar'),
        ),
      ],
    ),
  );
}
