import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/labeled_value_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы вернётесь на экран входа.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Да, выйти'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Студент CampusSpace',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    LabeledValueRow(label: 'Роль', value: 'Студент'),
                    LabeledValueRow(label: 'Группа', value: 'TI-235'),
                    LabeledValueRow(
                      label: 'Почта',
                      value: 'student@example.edu',
                    ),
                    LabeledValueRow(label: 'Кампус', value: 'UTM'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Профиль заполнен демонстрационными данными.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}
