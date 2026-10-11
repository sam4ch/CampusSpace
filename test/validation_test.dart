import 'package:campus_space/data/mock_data.dart';
import 'package:campus_space/validation/auth_validators.dart';
import 'package:campus_space/validation/booking_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final room = MockData.rooms.first;
  final now = DateTime(2026, 10, 11, 12);

  test('Email, password and name rules', () {
    for (final email in ['', 'samir', '@utm.md', 'a@@utm.md', 'a b@utm.md']) {
      expect(AuthValidators.email(email), isNotNull);
    }
    expect(AuthValidators.email(' student@utm.md '), isNull);
    expect(AuthValidators.password('12345'), isNotNull);
    expect(AuthValidators.password('123456'), isNull);
    expect(AuthValidators.name('   '), isNotNull);
    expect(AuthValidators.name('Samir'), isNull);
  });

  test('Dates reject impossible and past values, including leap years', () {
    expect(BookingValidators.parseDate('31.02.2027'), isNull);
    expect(BookingValidators.parseDate('29.02.2027'), isNull);
    expect(BookingValidators.parseDate('29.02.2028'), DateTime(2028, 2, 29));
    expect(BookingValidators.date('', now: now), isNotNull);
    expect(BookingValidators.date('10.10.2026', now: now), isNotNull);
    expect(BookingValidators.date('11.10.2026', now: now), isNull);
  });

  test('Time must be real, future, ordered and inside opening hours', () {
    expect(BookingValidators.parseTime('24:00'), isNull);
    expect(BookingValidators.parseTime('12:60'), isNull);
    expect(
      BookingValidators.start('11:00', '11.10.2026', room, now: now),
      isNotNull,
    );
    expect(
      BookingValidators.start('07:59', '12.10.2026', room, now: now),
      isNotNull,
    );
    expect(
      BookingValidators.start('08:00', '12.10.2026', room, now: now),
      isNull,
    );
    expect(BookingValidators.end('10:00', '10:00', room), isNotNull);
    expect(BookingValidators.end('09:00', '10:00', room), isNotNull);
    expect(BookingValidators.end('20:01', '19:00', room), isNotNull);
    expect(BookingValidators.end('20:00', '19:00', room), isNull);
  });

  test('Capacity boundaries and required purpose', () {
    for (final count in ['', '0', '-1', '2.5', '31']) {
      expect(BookingValidators.participants(count, 30), isNotNull);
    }
    expect(BookingValidators.participants('1', 30), isNull);
    expect(BookingValidators.participants('30', 30), isNull);
    expect(BookingValidators.purpose('  '), isNotNull);
    expect(BookingValidators.purpose('Встреча команды'), isNull);
  });
}
