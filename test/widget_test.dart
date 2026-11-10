import 'package:campus_space/data/mock_settings.dart';
import 'package:campus_space/models/booking.dart';
import 'package:campus_space/models/booking_model.dart';
import 'package:campus_space/models/room_model.dart';
import 'package:provider/provider.dart';
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
  await tester.pumpWidget(
    CampusSpaceRoot(
      routerConfig: router,
      settings: MockSettings(latency: const Duration(milliseconds: 30)),
    ),
  );
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
  for (final path in [
    '/rooms/r1',
    '/favorites',
    '/bookings',
    '/bookings/B-1048',
    '/rooms/r1/booking',
    '/profile',
  ]) {
    testWidgets('Loading error and recovery on $path', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = createRouter(initialLocation: path);
      addTearDown(router.dispose);
      final settings = MockSettings()..simulateError = true;
      await tester.pumpWidget(
        CampusSpaceRoot(routerConfig: router, settings: settings),
      );
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text(MockSettings.networkError), findsOneWidget);
      settings.simulateError = false;
      await press(tester, 'Повторить');
      expect(find.text(MockSettings.networkError), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
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
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        )
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

  testWidgets('Booking validates all fields and saves through model', (
    tester,
  ) async {
    final router = await start(tester, '/rooms/r1/booking');
    final model = tester
        .element(find.byType(CampusSpaceApp))
        .read<BookingModel>();
    final before = model.bookings.length;
    await press(tester, 'Отправить заявку');
    expect(router.routeInformationProvider.value.uri.path, '/rooms/r1/booking');
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
    expect(find.text('Заявка создана'), findsOneWidget);
    expect(model.bookings.length, before + 1);
  });

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
      await tester.ensureVisible(find.text('Выйти из аккаунта'));
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

  testWidgets('Cancellation changes status and active count', (tester) async {
    await start(tester, '/bookings/B-1048');
    final model = tester
        .element(find.byType(CampusSpaceApp))
        .read<BookingModel>();
    final before = model.activeCount;
    await tester.ensureVisible(find.text('Отменить бронирование'));
    await tester.tap(find.text('Отменить бронирование'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Оставить'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('Отменить бронирование'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Да, отменить'));
    await tester.pumpAndSettle();
    expect(find.text('Бронирование отменено'), findsOneWidget);
    expect(model.byId('B-1048')!.status, BookingStatus.cancelled);
    expect(model.activeCount, before - 1);
  });

  testWidgets('Favorites update details, badge, list and survive navigation', (
    tester,
  ) async {
    final router = await start(tester, '/rooms/r5');
    final model = tester.element(find.byType(CampusSpaceApp)).read<RoomModel>();
    expect(model.favoriteCount, 6);
    await tester.ensureVisible(find.byKey(const ValueKey('toggleFavorite')));
    await tester.tap(find.byKey(const ValueKey('toggleFavorite')));
    await tester.pumpAndSettle();
    expect(model.favoriteCount, 7);
    expect(find.text('Убрать из избранного'), findsOneWidget);
    router.go('/favorites');
    await tester.pumpAndSettle();
    expect(find.text('Избранное (7)'), findsOneWidget);
    final item = find.byKey(const ValueKey('r5'));
    await tester.scrollUntilVisible(item, 200);
    await tester.drag(item, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(model.favoriteCount, 6);
    expect(find.text('Избранное (6)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Loading error retry and recovery are visible', (tester) async {
    await start(tester, '/rooms');
    final settings = tester
        .element(find.byType(CampusSpaceApp))
        .read<MockSettings>();
    settings.latency = const Duration(milliseconds: 800);
    settings.simulateError = true;
    await tester.tap(find.byTooltip('Обновить каталог'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(MockSettings.networkError), findsOneWidget);
    await press(tester, 'Повторить');
    expect(find.text(MockSettings.networkError), findsOneWidget);
    settings.simulateError = false;
    await press(tester, 'Повторить');
    expect(find.text('Аудитория 3-304'), findsOneWidget);
  });

  testWidgets('Failed submit preserves fields and does not add booking', (
    tester,
  ) async {
    await start(tester, '/rooms/r1/booking');
    final ctx = tester.element(find.byType(CampusSpaceApp));
    final before = ctx.read<BookingModel>().bookings.length;
    await type(tester, 'bookingDate', '31.12.2099');
    await type(tester, 'bookingStart', '10:00');
    await type(tester, 'bookingEnd', '11:00');
    await type(tester, 'bookingParticipants', '12');
    await type(tester, 'bookingPurpose', 'Ошибка сохранения');
    ctx.read<MockSettings>().simulateError = true;
    await press(tester, 'Отправить заявку');
    expect(find.text(MockSettings.networkError), findsOneWidget);
    expect(find.text('Ошибка сохранения'), findsOneWidget);
    expect(ctx.read<BookingModel>().bookings.length, before);
    ctx.read<MockSettings>().simulateError = false;
    await press(tester, 'Отправить заявку');
    expect(ctx.read<BookingModel>().bookings.length, before + 1);
  });

  testWidgets('Delete confirmation removes entity from all consumers', (
    tester,
  ) async {
    final router = await start(tester, '/bookings/B-1048');
    final model = tester
        .element(find.byType(CampusSpaceApp))
        .read<BookingModel>();
    final before = model.bookings.length;
    final button = find.text('Удалить заявку');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Оставить'));
    await tester.pumpAndSettle();
    expect(model.bookings.length, before);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await press(tester, 'Удалить');
    expect(model.bookings.length, before - 1);
    expect(model.byId('B-1048'), isNull);
    router.go('/bookings/B-1048');
    await tester.pumpAndSettle();
    expect(find.text('Страница не найдена'), findsOneWidget);
  });
}
