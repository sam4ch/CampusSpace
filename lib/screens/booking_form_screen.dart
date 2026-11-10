import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../models/booking.dart';
import '../widgets/data_view.dart';
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
  bool _submitting = false;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _participantsCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final error = await context.read<BookingModel>().add(Booking(
      id: '', roomId: widget.roomId, date: _dateCtrl.text.trim(),
      time: '${_startCtrl.text.trim()}–${_endCtrl.text.trim()}',
      participants: int.parse(_participantsCtrl.text),
      purpose: _purposeCtrl.text.trim(), status: BookingStatus.pending,
    ));
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return; // Controllers keep their values on error.
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заявка создана')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomModel>();
    final bookings = context.watch<BookingModel>();
    final room = rooms.byId(widget.roomId);
    return Scaffold(
      appBar: AppBar(title: const Text('Новое бронирование')),
      body: SafeArea(child: DataView(models: [rooms, bookings],
        onRetry: () { context.read<RoomModel>().load(); context.read<BookingModel>().load(); },
        builder: (context) {
          if (room == null) return const NotFoundScreen();
          return Form(
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
                onPressed: _submitting || bookings.isSaving ? null : _submit,
                child: Text(_submitting ? 'Сохранение…' : 'Отправить заявку'),
              ),
              const SizedBox(height: 8),
              Text(
                'L4: заявка сохранится в памяти до перезапуска приложения.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          );
        },
      )),
    );
  }
}
