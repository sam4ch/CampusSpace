import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/booking.dart';
import '../widgets/booking_status_badge.dart';
import '../widgets/labeled_value_row.dart';
import 'not_found_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _cancel(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Отменить бронирование?'),
        content: const Text(
          'Учебная демонстрация: статус заявки не изменится.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Оставить'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Да, отменить'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отмена подтверждена. Демо: статус не изменён.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = MockData.findBooking(id);
    if (booking == null) return const NotFoundScreen();
    final room = MockData.roomById(booking.roomId);
    return Scaffold(
      appBar: AppBar(title: Text('Заявка ${booking.id}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 16),
            LabeledValueRow(label: 'Номер заявки', value: booking.id),
            LabeledValueRow(label: 'Дата', value: booking.date),
            LabeledValueRow(label: 'Время', value: booking.time),
            LabeledValueRow(
              label: 'Участники',
              value: '${booking.participants} человек',
            ),
            LabeledValueRow(label: 'Цель', value: booking.purpose),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: const Text('О помещении'),
                subtitle: Text('${room.building} · ${room.floor} этаж'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/rooms/${room.id}'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Статус показан из локальных примеров. '
              'Реальные заявки и изменения статуса появятся на L5.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.approved) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _cancel(context),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Отменить бронирование'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
