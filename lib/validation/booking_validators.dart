import '../models/room.dart';

abstract final class BookingValidators {
  static DateTime? parseDate(String text) {
    final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(text.trim());
    if (match == null) return null;
    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day ? date : null;
  }

  static int? parseTime(String text) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text.trim());
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    return hour < 24 && minute < 60 ? hour * 60 + minute : null;
  }

  static String? date(String? value, {DateTime? now}) {
    if (value == null || value.trim().isEmpty) return 'Укажите дату';
    final date = parseDate(value);
    if (date == null) return 'Введите реальную дату ДД.ММ.ГГГГ';
    final today = now ?? DateTime.now();
    if (date.isBefore(DateTime(today.year, today.month, today.day))) {
      return 'Дата не может быть в прошлом';
    }
    return null;
  }

  static String? start(String? value, String dateText, Room room, {DateTime? now}) {
    if (value == null || value.trim().isEmpty) return 'Укажите время начала';
    final minutes = parseTime(value);
    if (minutes == null) return 'Введите время ЧЧ:ММ от 00:00 до 23:59';
    final hours = room.hours.split('–');
    if (minutes < parseTime(hours.first)! || minutes >= parseTime(hours.last)!) {
      return 'Начало должно быть в пределах ' + room.hours;
    }
    final day = parseDate(dateText);
    if (day != null && !day.add(Duration(minutes: minutes)).isAfter(now ?? DateTime.now())) {
      return 'Начало бронирования должно быть в будущем';
    }
    return null;
  }

  static String? end(String? value, String startText, Room room) {
    if (value == null || value.trim().isEmpty) return 'Укажите время окончания';
    final minutes = parseTime(value);
    if (minutes == null) return 'Введите время ЧЧ:ММ от 00:00 до 23:59';
    final hours = room.hours.split('–');
    if (minutes <= parseTime(hours.first)! || minutes > parseTime(hours.last)!) {
      return 'Окончание должно быть в пределах ' + room.hours;
    }
    final start = parseTime(startText);
    if (start != null && minutes <= start) return 'Окончание должно быть позже начала';
    return null;
  }

  static String? participants(String? value, int capacity) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count < 1) return 'Укажите целое число от 1';
    if (count > capacity) return 'Вместимость помещения — $capacity человек';
    return null;
  }

  static String? purpose(String? value) => value == null || value.trim().isEmpty
      ? 'Укажите цель бронирования' : null;
}
