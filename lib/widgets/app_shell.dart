import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/room_model.dart';
import '../models/booking_model.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: navigationShell.goBranch,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.meeting_room_outlined),
          label: 'Каталог',
        ),
        NavigationDestination(
          icon: Consumer<BookingModel>(
            builder: (_, model, child) =>
                Badge(label: Text('${model.activeCount}'), child: child!),
            child: const Icon(Icons.event_note_outlined),
          ),
          label: 'Мои заявки',
        ),
        NavigationDestination(
          icon: Consumer<RoomModel>(
            builder: (_, model, child) =>
                Badge(label: Text('${model.favoriteCount}'), child: child!),
            child: const Icon(Icons.favorite_border),
          ),
          label: 'Избранное',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Профиль',
        ),
      ],
    ),
  );
}
