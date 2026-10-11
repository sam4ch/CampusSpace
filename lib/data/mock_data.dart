import '../models/booking.dart';
import '../models/room.dart';

/// Demonstration data for L2. These are examples, not the university's live timetable.
abstract final class MockData {
  static const rooms = <Room>[
    Room(id: 'r1', name: 'Аудитория 3-304', building: 'Корпус 3', floor: 3,
        type: 'Учебная аудитория', capacity: 30,
        equipment: ['Проектор', 'Wi-Fi', 'Доска'],
        description: 'Светлая аудитория для занятий, консультаций и командной работы.',
        hours: '08:00–20:00'),
    Room(id: 'r2', name: 'Переговорная 3-501', building: 'Корпус 3', floor: 5,
        type: 'Переговорная', capacity: 8,
        equipment: ['Экран', 'Видеосвязь', 'Wi-Fi'],
        description: 'Тихое пространство для встреч проектных команд.',
        hours: '09:00–19:00'),
    Room(id: 'r3', name: 'Лаборатория IoT 3-210', building: 'Корпус 3', floor: 2,
        type: 'Лаборатория', capacity: 16,
        equipment: ['Компьютеры', 'Наборы IoT', 'Проектор'],
        description: 'Рабочие места для прототипирования устройств и практических занятий.',
        hours: '09:00–18:00'),
    Room(id: 'r4', name: 'Медиа-зал 3-402', building: 'Корпус 3', floor: 4,
        type: 'Медиа-зал', capacity: 24,
        equipment: ['Проектор', 'Звук', 'Микрофон'],
        description: 'Зал для презентаций, открытых лекций и студенческих мероприятий.',
        hours: '08:00–21:00'),
    Room(id: 'r5', name: 'Семинарская 1-118', building: 'Корпус 1', floor: 1,
        type: 'Учебная аудитория', capacity: 20,
        equipment: ['Доска', 'Wi-Fi'],
        description: 'Компактная аудитория для семинаров и групповых обсуждений.',
        hours: '08:00–20:00'),
    Room(id: 'r6', name: 'Коворкинг 2-602', building: 'Корпус 2', floor: 6,
        type: 'Коворкинг', capacity: 18,
        equipment: ['Розетки', 'Wi-Fi', 'Маркерная доска'],
        description: 'Гибкое пространство для самостоятельной и совместной работы.',
        hours: '08:00–22:00'),
    Room(id: 'r7', name: 'Робототехника 2-214', building: 'Корпус 2', floor: 2,
        type: 'Лаборатория', capacity: 12,
        equipment: ['Компьютеры', 'Робототехника', '3D-принтер'],
        description: 'Лаборатория для инженерных прототипов и учебных проектов.',
        hours: '09:00–18:00'),
    Room(id: 'r8', name: 'Конференц-зал 1-101', building: 'Корпус 1', floor: 1,
        type: 'Конференц-зал', capacity: 60,
        equipment: ['Проектор', 'Звук', 'Видеосвязь'],
        description: 'Большой зал для конференций, защит и встреч сообщества.',
        hours: '08:00–20:00'),
  ];

  static const favoriteRoomIds = <String>['r1', 'r2', 'r3', 'r4', 'r6', 'r8'];

  static const bookings = <Booking>[
    Booking(id: 'B-1048', roomId: 'r2', date: '18 октября 2026', time: '14:00–15:30',
        participants: 6, purpose: 'Встреча команды проекта', status: BookingStatus.approved),
    Booking(id: 'B-1047', roomId: 'r3', date: '19 октября 2026', time: '10:00–12:00',
        participants: 12, purpose: 'Практикум по IoT', status: BookingStatus.pending),
    Booking(id: 'B-1046', roomId: 'r4', date: '21 октября 2026', time: '16:00–18:00',
        participants: 20, purpose: 'Презентация проекта', status: BookingStatus.pending),
    Booking(id: 'B-1045', roomId: 'r1', date: '7 октября 2026', time: '12:00–13:30',
        participants: 18, purpose: 'Учебная консультация', status: BookingStatus.completed),
    Booking(id: 'B-1044', roomId: 'r6', date: '5 октября 2026', time: '17:00–19:00',
        participants: 8, purpose: 'Работа над макетом', status: BookingStatus.completed),
    Booking(id: 'B-1043', roomId: 'r8', date: '3 октября 2026', time: '10:00–12:00',
        participants: 30, purpose: 'Открытая лекция', status: BookingStatus.rejected),
    Booking(id: 'B-1042', roomId: 'r5', date: '1 октября 2026', time: '15:00–16:00',
        participants: 12, purpose: 'Семинар группы', status: BookingStatus.cancelled),
    Booking(id: 'B-1041', roomId: 'r7', date: '29 сентября 2026', time: '11:00–13:00',
        participants: 10, purpose: 'Практика по робототехнике', status: BookingStatus.completed),
  ];

  static Room roomById(String id) => rooms.firstWhere((room) => room.id == id);
}
