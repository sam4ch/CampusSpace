import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../validation/booking_validators.dart';
import 'not_found_screen.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.roomId});
  final String roomId;
  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _participantsCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  @override
  void dispose() {
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _participantsCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заявка проверена. Демо: данные не сохранены.'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final room = MockData.findRoom(widget.roomId);
    if (room == null) return const NotFoundScreen();
    return Scaffold(
      appBar: AppBar(title: const Text('Новое бронирование')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(room.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '${room.building} · До ${room.capacity} человек · ${room.hours}',
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('bookingDate'),
                controller: _dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Дата',
                  hintText: 'ДД.ММ.ГГГГ',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                textInputAction: TextInputAction.next,
                validator: BookingValidators.date,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('bookingStart'),
                controller: _startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Время начала',
                  hintText: '10:00',
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    BookingValidators.start(value, _dateCtrl.text, room),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('bookingEnd'),
                controller: _endCtrl,
                decoration: const InputDecoration(
                  labelText: 'Время окончания',
                  hintText: '11:30',
                  prefixIcon: Icon(Icons.access_time_filled),
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    BookingValidators.end(value, _startCtrl.text, room),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('bookingParticipants'),
                controller: _participantsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Количество участников',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    BookingValidators.participants(value, room.capacity),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('bookingPurpose'),
                controller: _purposeCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Цель бронирования',
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                validator: BookingValidators.purpose,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('bookingSubmit'),
                onPressed: _submit,
                child: const Text('Отправить заявку'),
              ),
              const SizedBox(height: 8),
              Text(
                'Учебная демонстрация: заявка проверяется без сохранения.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
