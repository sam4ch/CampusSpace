import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_settings.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../widgets/data_view.dart';
import '../widgets/labeled_value_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _simulateError = false;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<MockSettings>();
    _simulateError = settings.simulateError;
    _slow = settings.latency.inSeconds >= 3;
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Вы вернётесь на экран входа. Учебные данные остаются в памяти до перезапуска.',
        ),
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
    if (ok == true && mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomModel>();
    final bookings = context.watch<BookingModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Icon(Icons.person_outline, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Учебный режим CampusSpace',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Вход и регистрация проверяют поля локально. Серверная учётная запись появится на L5.',
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: DataView(
                models: [rooms, bookings],
                onRetry: () {
                  context.read<RoomModel>().load();
                  context.read<BookingModel>().load();
                },
                builder: (_) => Column(
                  children: [
                    LabeledValueRow(
                      label: 'Помещений',
                      value: '${rooms.rooms.length}',
                    ),
                    LabeledValueRow(
                      label: 'В избранном',
                      value: '${rooms.favoriteCount}',
                    ),
                    LabeledValueRow(
                      label: 'Всего заявок',
                      value: '${bookings.bookings.length}',
                    ),
                    LabeledValueRow(
                      label: 'Активных заявок',
                      value: '${bookings.activeCount}',
                    ),
                  ],
                ),
              ),
            ),
            // The only screen that knows about mock infrastructure. Remove on L5.
            SwitchListTile(
              key: const ValueKey('simulateError'),
              title: const Text('Симулировать сбой сети'),
              subtitle: const Text(
                'Включите и обновите каталог или отправьте форму.',
              ),
              value: _simulateError,
              onChanged: (value) {
                context.read<MockSettings>().simulateError = value;
                setState(() => _simulateError = value);
              },
            ),
            SwitchListTile(
              key: const ValueKey('slowLoading'),
              title: const Text('Задержка 3 секунды для скриншота'),
              value: _slow,
              onChanged: (value) {
                context.read<MockSettings>().latency = Duration(
                  milliseconds: value ? 3000 : 800,
                );
                setState(() => _slow = value);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'L4: данные хранятся только в памяти. Hot restart восстанавливает начальные примеры.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}
