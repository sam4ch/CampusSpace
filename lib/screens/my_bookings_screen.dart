import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/booking_card.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои бронирования')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'История заявок',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${MockData.bookings.length} примеров со статусами',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            for (final booking in MockData.bookings)
              BookingCard(
                booking: booking,
                room: MockData.roomById(booking.roomId),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BookingDetailScreen(booking: booking),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
