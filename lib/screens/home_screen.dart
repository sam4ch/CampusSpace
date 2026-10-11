import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'booking_detail_screen.dart';
import 'booking_form_screen.dart';
import 'favorites_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';
import 'room_catalog_screen.dart';
import 'room_detail_screen.dart';

/// Simple screen gallery for L2; routing will be replaced by go_router in L3.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <(String, IconData, Widget)>[
      ('Каталог помещений', Icons.search, const RoomCatalogScreen()),
      (
        'Карточка помещения',
        Icons.meeting_room_outlined,
        RoomDetailScreen(room: MockData.rooms.first),
      ),
      (
        'Новое бронирование',
        Icons.event_available_outlined,
        BookingFormScreen(room: MockData.rooms.first),
      ),
      ('Мои бронирования', Icons.event_note_outlined, const MyBookingsScreen()),
      (
        'Детали бронирования',
        Icons.receipt_long_outlined,
        BookingDetailScreen(booking: MockData.bookings.first),
      ),
      ('Избранное', Icons.favorite_outline, const FavoritesScreen()),
      ('Профиль', Icons.person_outline, const ProfileScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CampusSpace')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Помещения кампуса',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Демонстрация экранов лабораторной № 2. '
              'Данные и статусы ниже — примеры.',
            ),
            const SizedBox(height: 16),
            for (final (title, icon, screen) in screens)
              Card(
                child: ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => screen),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
