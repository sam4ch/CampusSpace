import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/booking.dart';
import '../widgets/booking_status_badge.dart';
import '../widgets/labeled_value_row.dart';
import 'room_detail_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => RoomDetailScreen(room: room),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Статус показан из локальных примеров. '
              'Реальные заявки и изменения статуса появятся на L5.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
