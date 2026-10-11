import 'package:campus_space/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('L2 demo opens the room catalog', (tester) async {
    await tester.pumpWidget(const CampusSpaceApp());

    expect(find.text('CampusSpace'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Каталог помещений'));
    await tester.pumpAndSettle();

    expect(find.text('Аудитория 3-304'), findsOneWidget);
    expect(find.text('Фильтры'), findsOneWidget);
  });
}
