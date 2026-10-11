import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/room_card.dart';
import 'room_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.rooms.where(
      (room) => MockData.favoriteRoomIds.contains(room.id),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Сохранённые помещения',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${rooms.length} помещений · примерный список',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            for (final room in rooms)
              RoomCard(
                room: room,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => RoomDetailScreen(room: room),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
