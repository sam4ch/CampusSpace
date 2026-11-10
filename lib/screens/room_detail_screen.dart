import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../widgets/data_view.dart';
import '../widgets/labeled_value_row.dart';
import 'not_found_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RoomModel>();
    final bookings = context.watch<BookingModel>();
    final room = model.byId(id);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(room?.name ?? 'Помещение')),
      body: SafeArea(child: DataView(models: [model, bookings],
        onRetry: () {
          context.read<RoomModel>().load();
          context.read<BookingModel>().load();
        },
        builder: (context) {
          if (room == null) return const NotFoundScreen();
          final occupied = bookings.bookings.where((b) => b.roomId == id && b.isActive).toList();
          return ListView(
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
              'Активные заявки на помещение',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (occupied.isEmpty) const Text('Активных заявок нет'),
            for (final booking in occupied)
              ListTile(key: ValueKey(booking.id),
                leading: const Icon(Icons.event_note),
                title: Text('${booking.date} · ${booking.time}'),
                subtitle: Text(booking.purpose),
                onTap: () => context.push('/bookings/${booking.id}')),
            OutlinedButton.icon(
              key: const ValueKey('toggleFavorite'),
              onPressed: model.isSaving ? null : () async {
                final error = await context.read<RoomModel>().toggleFavorite(id);
                if (!context.mounted) return;
                if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              },
              icon: Icon(room.isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text(room.isFavorite ? 'Убрать из избранного' : 'В избранное'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  context.push('${GoRouterState.of(context).uri.path}/booking'),
              icon: const Icon(Icons.add),
              label: const Text('Выбрать помещение'),
            ),
          ],
          );
        },
      )),
    );
  }
}
