import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/room_model.dart';
import 'models/booking_model.dart';
import 'data/room_repository.dart';
import 'data/booking_repository.dart';
import 'data/mock_room_repository.dart';
import 'data/mock_booking_repository.dart';
import 'data/mock_settings.dart';
import 'router.dart';

void main() => runApp(CampusSpaceRoot());

/// Composition root: replace concrete repositories here on L5, not in screens.
class CampusSpaceRoot extends StatelessWidget {
  CampusSpaceRoot({super.key, this.routerConfig, MockSettings? settings,
    RoomRepository? roomRepository, BookingRepository? bookingRepository}) {
    this.settings = settings ?? MockSettings();
    rooms = roomRepository ?? MockRoomRepository(this.settings);
    bookings = bookingRepository ?? MockBookingRepository(this.settings, rooms);
  }
  final GoRouter? routerConfig;
  late final MockSettings settings;
  late final RoomRepository rooms;
  late final BookingRepository bookings;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<MockSettings>.value(value: settings), // Demo scaffold only.
      Provider<RoomRepository>.value(value: rooms),
      Provider<BookingRepository>.value(value: bookings),
      ChangeNotifierProvider(create: (_) => RoomModel(rooms)..load()),
      ChangeNotifierProvider(create: (_) => BookingModel(bookings)..load()),
    ],
    child: CampusSpaceApp(routerConfig: routerConfig),
  );
}

class CampusSpaceApp extends StatelessWidget {
  const CampusSpaceApp({super.key, this.routerConfig});

  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CampusSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246A73)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: routerConfig ?? router,
    );
  }
}
