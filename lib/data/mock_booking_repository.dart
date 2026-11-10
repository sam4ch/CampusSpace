import '../models/booking.dart';
import '../validation/booking_validators.dart';
import 'booking_repository.dart';
import 'mock_data.dart';
import 'mock_repository.dart';
import 'mock_settings.dart';
import 'result.dart';
import 'room_repository.dart';

class MockBookingRepository extends MockRepository<Booking>
    implements BookingRepository {
  MockBookingRepository(
    MockSettings settings,
    this.rooms, {
    List<Booking>? seed,
  }) : super(settings, seed ?? _seed());
  final RoomRepository rooms;
  @override
  String idOf(Booking item) => item.id;
  @override
  Booking withId(Booking draft, String id) => draft.copyWith(id: id);
  @override
  String get idPrefix => 'B-';
  @override
  String get missingMessage => 'Заявка не существует';

  static List<Booking> _seed() => [
    for (var i = 0; i < MockData.bookings.length; i++)
      MockData.bookings[i].copyWith(
        date: _date(
          DateTime.now().add(
            Duration(days: MockData.bookings[i].isActive ? i + 2 : -i - 1),
          ),
        ),
      ),
  ];

  static String _date(DateTime day) =>
      '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';

  @override
  Future<String?> validate(Booking item) async {
    // Cancellation keeps an historical booking valid without rechecking its date.
    if (!item.isActive) return null;
    final result = await rooms.fetchById(item.roomId);
    switch (result) {
      case Err(:final msg):
        return msg;
      case Ok(:final value):
        final parts = item.time.split('–');
        if (parts.length != 2) return 'Укажите интервал времени';
        final errors = [
          BookingValidators.date(item.date),
          BookingValidators.start(parts[0], item.date, value),
          BookingValidators.end(parts[1], parts[0], value),
          BookingValidators.participants(
            '${item.participants}',
            value.capacity,
          ),
          BookingValidators.purpose(item.purpose),
        ];
        for (final error in errors) {
          if (error != null) return error;
        }
        final start = BookingValidators.parseTime(parts[0])!;
        final end = BookingValidators.parseTime(parts[1])!;
        for (final other in snapshot) {
          if (other.id == item.id ||
              !other.isActive ||
              other.roomId != item.roomId ||
              other.date != item.date) {
            continue;
          }
          final interval = other.time.split('–');
          if (start < BookingValidators.parseTime(interval[1])! &&
              end > BookingValidators.parseTime(interval[0])!) {
            return 'Помещение уже занято в выбранное время';
          }
        }
        return null;
    }
  }
}
