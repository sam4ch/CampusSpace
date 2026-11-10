import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/booking_model.dart';
import '../models/room_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_actions.dart';
import '../widgets/data_view.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookingModel>();
    final rooms = context.watch<RoomModel>();
    void reload() {
      context.read<BookingModel>().load();
      context.read<RoomModel>().load();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои бронирования'),
        actions: [
          IconButton(
            tooltip: 'Обновить заявки',
            onPressed: model.isLoading || model.isSaving ? null : reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: DataView(
          models: [model, rooms],
          onRetry: reload,
          builder: (_) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Всего заявок: ${model.bookings.length} · активных: ${model.activeCount}',
                ),
              ),
              Expanded(
                child: model.bookings.isEmpty
                    ? const Center(
                        child: Text(
                          'Заявок пока нет. Выберите помещение в каталоге.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: model.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = model.bookings[index];
                          return Dismissible(
                            key: ValueKey(booking.id),
                            direction: model.isSaving
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            background: ColoredBox(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer,
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Icon(Icons.delete_outline),
                                ),
                              ),
                            ),
                            confirmDismiss: (_) async {
                              await deleteBooking(context, booking.id);
                              return false; // Successful model mutation already removes this row.
                            },
                            child: BookingCard(
                              booking: booking,
                              room: rooms.byId(booking.roomId),
                              onTap: () =>
                                  context.push('/bookings/${booking.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
