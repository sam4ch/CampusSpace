import 'package:flutter/material.dart';

import '../widgets/labeled_value_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    LabeledValueRow(label: 'Группа', value: 'ISA-241'),
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
          ],
        ),
      ),
    );
  }
}
