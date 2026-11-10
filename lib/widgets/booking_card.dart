import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/room.dart';
import 'booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.room,
    required this.onTap,
  });

  final Booking booking;
  final Room? room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room?.name ?? 'Помещение ${booking.roomId} недоступно',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  BookingStatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(booking.id),
              Text('${booking.date} · ${booking.time}'),
              const SizedBox(height: 4),
              Text(
                booking.purpose,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
