import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import '../widgets/data_view.dart';
import '../widgets/booking_actions.dart';
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
          'Статус изменится на «Отменено», а время помещения освободится.',
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
      final error = await context.read<BookingModel>().cancel(id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? 'Бронирование отменено'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookingModel>();
    final rooms = context.watch<RoomModel>();
    final booking = model.byId(id);
    final room = booking == null ? null : rooms.byId(booking.roomId);
    return Scaffold(
      appBar: AppBar(title: Text('Заявка $id')),
      body: SafeArea(child: DataView(models: [model, rooms],
        onRetry: () { context.read<BookingModel>().load(); context.read<RoomModel>().load(); },
        builder: (context) {
          if (booking == null) return const NotFoundScreen();
          return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room?.name ?? 'Помещение ${booking.roomId} недоступно',
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
                subtitle: Text(room == null ? 'Помещение недоступно' : '${room.building} · ${room.floor} этаж'),
                trailing: const Icon(Icons.chevron_right),
                onTap: room == null ? null : () => context.go('/rooms/${room.id}'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'L4: изменения хранятся в памяти до перезапуска приложения.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.approved) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: model.isSaving ? null : () => _cancel(context),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Отменить бронирование'),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: model.isSaving ? null : () async {
                final deleted = await deleteBooking(context, id);
                if (deleted && context.mounted) {
                  if (context.canPop()) { context.pop(); } else { context.go('/bookings'); }
                }
              },
              icon: const Icon(Icons.delete_outline), label: const Text('Удалить заявку'),
            ),
          ],
          );
        },
      )),
    );
  }
}
