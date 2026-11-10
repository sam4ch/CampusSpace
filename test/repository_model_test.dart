import 'package:flutter_test/flutter_test.dart';
import 'package:campus_space/data/mock_room_repository.dart';
import 'package:campus_space/data/mock_booking_repository.dart';
import 'package:campus_space/data/mock_settings.dart';
import 'package:campus_space/data/result.dart';
import 'package:campus_space/models/room.dart';
import 'package:campus_space/models/booking.dart';
import 'package:campus_space/models/room_model.dart';
import 'package:campus_space/models/booking_model.dart';

void main() {
  late MockSettings settings;
  late MockRoomRepository rooms;
  late MockBookingRepository bookings;
  setUp(() {
    settings = MockSettings(latency: Duration.zero);
    rooms = MockRoomRepository(settings);
    bookings = MockBookingRepository(settings, rooms);
  });
  const draft = Booking(
    id: '',
    roomId: 'r1',
    date: '31.12.2099',
    time: '10:00–11:00',
    participants: 12,
    purpose: 'Командная работа',
    status: BookingStatus.pending,
  );

  test('Room repository supports CRUD and storage-generated IDs', () async {
    final seed = (await rooms.fetchAll() as Ok<List<Room>>).value;
    final created = (await rooms.create(seed.first) as Ok<Room>).value;
    expect(created.id, isNot(seed.first.id));
    expect(await rooms.fetchById(created.id), isA<Ok<Room>>());
    final updated = (await rooms.update(
      created.copyWith(isFavorite: true),
    ) as Ok<Room>).value;
    expect(updated.isFavorite, isTrue);
    expect(await rooms.delete(created.id), isA<Ok<void>>());
    expect(await rooms.fetchById(created.id), isA<Err<Room>>());
    expect(await rooms.update(created), isA<Err<Room>>());
    expect(await rooms.delete(created.id), isA<Err<void>>());
  });
  test('Repository returns copies and model exposes read-only data', () async {
    final list = (await rooms.fetchAll() as Ok<List<Room>>).value;
    list.clear();
    expect((await rooms.fetchAll() as Ok<List<Room>>).value.length, 8);
    final model = RoomModel(rooms);
    await model.load();
    expect(() => model.rooms.clear(), throwsUnsupportedError);
    expect(() => model.rooms.first.equipment.clear(), throwsUnsupportedError);
    expect(() => model.favorites.clear(), throwsUnsupportedError);
    model.dispose();
  });
  test(
    'All room CRUD operations fail without mutating during outage',
    () async {
      final room = (await rooms.fetchById('r1') as Ok<Room>).value;
      settings.simulateError = true;
      expect(await rooms.fetchAll(), isA<Err<List<Room>>>());
      expect(await rooms.fetchById('r1'), isA<Err<Room>>());
      expect(await rooms.create(room), isA<Err<Room>>());
      expect(await rooms.update(room), isA<Err<Room>>());
      expect(await rooms.delete('r1'), isA<Err<void>>());
      settings.simulateError = false;
      expect((await rooms.fetchAll() as Ok<List<Room>>).value.length, 8);
    },
  );
  test(
    'Loading notifies start and end, failed refresh keeps previous collection',
    () async {
      final model = RoomModel(rooms);
      final states = <bool>[];
      model.addListener(() => states.add(model.isLoading));
      await model.load();
      expect(states, [true, false]);
      settings.simulateError = true;
      await model.load();
      expect(model.error, MockSettings.networkError);
      expect(model.rooms.length, 8);
      settings.simulateError = false;
      await model.load();
      expect(model.error, isNull);
      model.dispose();
    },
  );
  test(
    'Favorite mutation persists to mock; failed mutation leaves it intact',
    () async {
      final model = RoomModel(rooms);
      await model.load();
      expect(model.favoriteCount, 6);
      await model.toggleFavorite('r5');
      expect(model.favoriteCount, 7);
      await model.load();
      expect(model.byId('r5')!.isFavorite, isTrue);
      settings.simulateError = true;
      expect(await model.toggleFavorite('r5'), isNotNull);
      expect(model.favoriteCount, 7);
      model.dispose();
    },
  );
  test(
    'Booking CRUD creates cancels deletes and handles missing IDs',
    () async {
      final model = BookingModel(bookings);
      await model.load();
      final active = model.activeCount;
      expect(await model.add(draft), isNull);
      final id = model.bookings.first.id;
      expect(id, 'B-2000');
      expect(model.activeCount, active + 1);
      expect(await bookings.fetchById(id), isA<Ok<Booking>>());
      expect(await model.cancel(id), isNull);
      expect(model.activeCount, active);
      expect(model.byId(id)!.status, BookingStatus.cancelled);
      expect(await model.remove(id), isNull);
      expect(model.byId(id), isNull);
      expect(await bookings.delete(id), isA<Err<void>>());
      expect(await bookings.fetchById(id), isA<Err<Booking>>());
      model.dispose();
    },
  );
  test('All booking CRUD methods fail during outage', () async {
    settings.simulateError = true;
    expect(await bookings.fetchAll(), isA<Err<List<Booking>>>());
    expect(await bookings.fetchById('B-1048'), isA<Err<Booking>>());
    expect(await bookings.create(draft), isA<Err<Booking>>());
    expect(await bookings.update(draft), isA<Err<Booking>>());
    expect(await bookings.delete('B-1048'), isA<Err<void>>());
  });
  test(
    'Overlapping bookings rejected; cancelled interval is available again',
    () async {
      final created = (await bookings.create(draft) as Ok<Booking>).value;
      expect(await bookings.create(draft), isA<Err<Booking>>());
      await bookings.update(created.copyWith(status: BookingStatus.cancelled));
      expect(await bookings.create(draft), isA<Ok<Booking>>());
    },
  );
  test('Failed write neither changes count nor stays busy', () async {
    final model = BookingModel(bookings);
    await model.load();
    final before = model.bookings.length;
    settings.simulateError = true;
    expect(await model.add(draft), MockSettings.networkError);
    expect(model.bookings.length, before);
    expect(model.isSaving, isFalse);
    model.dispose();
  });
  test(
    'Duplicate submits are rejected while an operation is in progress',
    () async {
      settings.latency = const Duration(milliseconds: 10);
      final model = BookingModel(bookings);
      await model.load();
      final before = model.bookings.length;
      final first = model.add(draft);
      expect(await model.add(draft), isNotNull);
      expect(await first, isNull);
      expect(model.bookings.length, before + 1);
      model.dispose();
    },
  );
  test('Disposed model does not notify after pending load', () async {
    settings.latency = const Duration(milliseconds: 5);
    final model = RoomModel(rooms);
    final loading = model.load();
    model.dispose();
    await expectLater(loading, completes);
  });
}
