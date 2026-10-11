import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

void main() => runApp(const CampusSpaceApp());

class CampusSpaceApp extends StatelessWidget {
  const CampusSpaceApp({super.key, this.routerConfig});

  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CampusSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246A73)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: routerConfig ?? router,
    );
  }
}
