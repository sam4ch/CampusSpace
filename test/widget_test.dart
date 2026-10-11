import 'package:campus_space/data/mock_data.dart';
import 'package:campus_space/main.dart';
import 'package:campus_space/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<GoRouter> start(WidgetTester tester, [String path = '/login']) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = createRouter(initialLocation: path);
  addTearDown(router.dispose);
  await tester.pumpWidget(CampusSpaceApp(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

Future<void> type(WidgetTester tester, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
}

Future<void> press(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Invalid login stays outside shell; valid login removes back path',
    (tester) async {
      final router = await start(tester);
      await press(tester, 'Войти');
      expect(find.text('Введите почту'), findsOneWidget);
      expect(
        find.text('Пароль должен содержать минимум 6 символов'),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
      await type(tester, 'loginEmail', 'student@utm.md');
      await type(tester, 'loginPassword', '123456');
      await press(tester, 'Войти');
      expect(router.routeInformationProvider.value.uri.path, '/rooms');
      expect(router.canPop(), isFalse);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('Tabs retain scroll and nested detail stack', (tester) async {
    final router = await start(tester, '/rooms');
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final scroll = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    final offset = scroll.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Каталог'));
    await tester.pumpAndSettle();
    expect(scroll.pixels, closeTo(offset, 0.1));
    router.push('/rooms/r2');
    await tester.pumpAndSettle();
    expect(find.text('Переговорная 3-501'), findsWidgets);
    await tester.tap(find.text('Избранное').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Каталог'));
    await tester.pumpAndSettle();
    expect(find.text('Переговорная 3-501'), findsWidgets);
    expect(router.canPop(), isTrue);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Каталог помещений'), findsOneWidget);
  });

  testWidgets('Direct IDs resolve different rooms; unknown IDs do not crash', (
    tester,
  ) async {
    final router = await start(tester, '/rooms/r1');
    expect(find.text('Аудитория 3-304'), findsWidgets);
    router.go('/rooms/r2');
    await tester.pumpAndSettle();
    expect(find.text('Переговорная 3-501'), findsWidgets);
    router.go('/rooms/missing');
    await tester.pumpAndSettle();
    expect(find.text('Страница не найдена'), findsOneWidget);
    router.go('/bookings/missing');
    await tester.pumpAndSettle();
    expect(find.text('Страница не найдена'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Booking validates all fields and returns without growing mock list',
    (tester) async {
      final router = await start(tester, '/rooms/r1/booking');
      final before = MockData.bookings.length;
      await press(tester, 'Отправить заявку');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/rooms/r1/booking',
      );
      expect(find.text('Укажите дату'), findsOneWidget);
      await type(tester, 'bookingDate', '31.12.2099');
      await type(tester, 'bookingStart', '10:00');
      await type(tester, 'bookingEnd', '09:00');
      await type(tester, 'bookingParticipants', '31');
      await type(tester, 'bookingPurpose', 'Встреча команды');
      await press(tester, 'Отправить заявку');
      expect(find.text('Окончание должно быть позже начала'), findsOneWidget);
      expect(find.text('Вместимость помещения — 30 человек'), findsOneWidget);
      await type(tester, 'bookingEnd', '11:00');
      await type(tester, 'bookingParticipants', '12abc');
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('bookingParticipants')),
            )
            .controller!
            .text,
        '12',
      );
      await press(tester, 'Отправить заявку');
      expect(router.routeInformationProvider.value.uri.path, '/rooms/r1');
      expect(
        find.text('Заявка проверена. Демо: данные не сохранены.'),
        findsOneWidget,
      );
      expect(MockData.bookings.length, before);
    },
  );

  testWidgets('Registration validates and returns to login', (tester) async {
    final router = await start(tester, '/register');
    await press(tester, 'Создать аккаунт');
    expect(find.text('Введите имя'), findsOneWidget);
    await type(tester, 'registrationName', 'Samir');
    await type(tester, 'registrationEmail', 'samir@utm.md');
    await type(tester, 'registrationPassword', '123456');
    await press(tester, 'Создать аккаунт');
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Logout handles dismiss, no, yes and removes shell', (
    tester,
  ) async {
    final router = await start(tester, '/profile');
    Future<void> open() async {
      await tester.tap(find.text('Выйти из аккаунта'));
      await tester.pumpAndSettle();
    }

    await open();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    await open();
    await tester.tap(find.text('Нет'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await open();
    await tester.tap(find.text('Да, выйти'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(router.canPop(), isFalse);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Cancellation confirms intent without changing mock status', (
    tester,
  ) async {
    await start(tester, '/bookings/B-1048');
    final status = MockData.findBooking('B-1048')!.status;
    await tester.tap(find.text('Отменить бронирование'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Оставить'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('Отменить бронирование'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Да, отменить'));
    await tester.pumpAndSettle();
    expect(
      find.text('Отмена подтверждена. Демо: статус не изменён.'),
      findsOneWidget,
    );
    expect(MockData.findBooking('B-1048')!.status, status);
  });
}
