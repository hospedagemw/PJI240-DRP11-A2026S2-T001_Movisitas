import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String? whatsappNumber(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (raw.trim().startsWith('+')) {
    return digits.length >= 8 && digits.length <= 15 ? digits : null;
  }
  if (digits.length == 10 || digits.length == 11) return '55$digits';
  if (digits.startsWith('55') && (digits.length == 12 || digits.length == 13)) {
    return digits;
  }
  return null;
}

class ClientContact extends StatelessWidget {
  const ClientContact({super.key, required this.name, required this.phone});
  final String name;
  final String phone;
  @override
  Widget build(BuildContext context) {
    final number = whatsappNumber(phone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.trim().isNotEmpty) Text('Contato: $name'),
        if (phone.trim().isNotEmpty)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(phone),
              if (number != null)
                TextButton.icon(
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF087F5B),
                  ),
                  onPressed: () async {
                    try {
                      if (await launchUrl(
                        Uri.https('wa.me', '/$number'),
                        webOnlyWindowName: '_blank',
                      )) {
                        return;
                      }
                    } catch (_) {}
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Não foi possível abrir o WhatsApp.'),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
      ],
    );
  }
}
