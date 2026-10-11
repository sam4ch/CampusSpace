import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/labeled_value_row.dart';
import 'not_found_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final room = MockData.findRoom(id);
    if (room == null) return const NotFoundScreen();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.meeting_room_outlined,
                size: 88,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(room.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(room.description),
            const SizedBox(height: 20),
            LabeledValueRow(label: 'Корпус', value: room.building),
            LabeledValueRow(label: 'Этаж', value: '${room.floor}'),
            LabeledValueRow(label: 'Тип', value: room.type),
            LabeledValueRow(
              label: 'Вместимость',
              value: 'До ${room.capacity} человек',
            ),
            LabeledValueRow(label: 'Часы работы', value: room.hours),
            const SizedBox(height: 20),
            Text(
              'Оборудование',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final item in room.equipment) Chip(label: Text(item)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Пример расписания',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.event_available_outlined),
                title: Text('Сегодня: 10:00–12:00, 15:00–17:00'),
                subtitle: Text('Свободные интервалы — демонстрационные'),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  context.push('${GoRouterState.of(context).uri.path}/booking'),
              icon: const Icon(Icons.add),
              label: const Text('Выбрать помещение'),
            ),
          ],
        ),
      ),
    );
  }
}
