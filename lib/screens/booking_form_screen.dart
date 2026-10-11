import 'package:flutter/material.dart';

import '../models/room.dart';

class BookingFormScreen extends StatelessWidget {
  const BookingFormScreen({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новое бронирование')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(room.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${room.building} · До ${room.capacity} человек'),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Дата',
                hintText: 'Например, 18.10.2026',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Время начала',
                hintText: '14:00',
                prefixIcon: Icon(Icons.access_time),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Время окончания',
                hintText: '15:30',
                prefixIcon: Icon(Icons.access_time_filled),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Количество участников',
                hintText: '6',
                prefixIcon: Icon(Icons.people_outline),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Цель бронирования',
                hintText: 'Встреча команды проекта',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            const FilledButton(
              onPressed: null,
              child: Text('Отправить заявку'),
            ),
            const SizedBox(height: 8),
            Text(
              'Демо L2: форма не сохраняет данные. '
              'Проверка полей появится в L3.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
