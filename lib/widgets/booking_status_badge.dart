import 'package:flutter/material.dart';

import '../models/booking.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      BookingStatus.pending => (
        'Ожидает',
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      BookingStatus.approved => (
        'Подтверждена',
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      BookingStatus.rejected => (
        'Отклонена',
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      BookingStatus.cancelled => (
        'Отменена',
        colors.surfaceContainerHighest,
        colors.onSurface,
      ),
      BookingStatus.completed => (
        'Завершена',
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: TextStyle(color: foreground, fontSize: 12)),
    );
  }
}
