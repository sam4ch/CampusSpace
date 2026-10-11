import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Страница не найдена')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/rooms'),
        child: const Text('Открыть каталог'),
      ),
    ),
  );
}
