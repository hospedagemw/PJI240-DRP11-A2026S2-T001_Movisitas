import 'package:flutter/material.dart';

import 'pages/main_menu.dart';
import 'pages/connected_app.dart';

class MovisitasApp extends StatelessWidget {
  const MovisitasApp({super.key, this.connected = false});
  final bool connected;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Movisitas',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFED3237))
          .copyWith(
            primary: const Color(0xFFED3237),
            onPrimary: Colors.white,
            primaryContainer: const Color(0xFFFDE7E8),
            onPrimaryContainer: const Color(0xFF7A1115),
            secondary: const Color(0xFF383838),
          ),
      scaffoldBackgroundColor: const Color(0xFFF7F7F8),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
    ),
    home: connected ? const AuthGate() : const MainMenu(),
  );
}
