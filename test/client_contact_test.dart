import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:movisitas/pages/client_contact.dart';

void main() {
  test(
    'Normaliza telefone nacional e internacional sem produzir link inválido',
    () {
      expect(whatsappNumber('(11) 90000-0000'), '5511900000000');
      expect(whatsappNumber('+55 11 90000-0000'), '5511900000000');
      expect(whatsappNumber('5511900000000'), '5511900000000');
      expect(whatsappNumber('123'), isNull);
      expect(whatsappNumber(''), isNull);
    },
  );
  testWidgets(
    'Exibe contato e número; só oferece WhatsApp para número válido',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClientContact(
              name: 'Contato Exemplo',
              phone: '(11) 90000-0000',
            ),
          ),
        ),
      );
      expect(find.text('Contato: Contato Exemplo'), findsOneWidget);
      expect(find.text('(11) 90000-0000'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClientContact(name: 'Contato Exemplo', phone: '123'),
          ),
        ),
      );
      expect(find.text('WhatsApp'), findsNothing);
    },
  );
}
