import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movisitas/pages/user_form.dart';
void main() {
  testWidgets('Cadastro exige nome, email e senha válida antes de enviar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: UserForm(ownAccount: false))));
    await tester.tap(find.text('Salvar')); await tester.pump();
    expect(find.text('Informe o nome completo'), findsOneWidget);
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(find.text('Use de 8 a 128 caracteres'), findsOneWidget);
    expect(find.text('Novo usuário'), findsOneWidget);
  });
  testWidgets('Edição própria não oferece senha nem alteração de perfil', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: UserForm(ownAccount: true, user: {'id':'teste','full_name':'Administrador','role':'administrator','active':true}))));
    expect(find.text('Senha inicial'), findsNothing);
    expect(find.text('E-mail de acesso'), findsNothing);
    final dropdown = tester.widget<DropdownButtonFormField<String>>(find.byType(DropdownButtonFormField<String>));
    expect(dropdown.onChanged, isNull);
    expect(find.text('Seu acesso administrativo será mantido.'), findsOneWidget);
  });
}
