import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';

Future<bool> deleteBooking(BuildContext context, String id) async {
  final confirmed = await showDialog<bool>(context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Удалить заявку?'),
      content: Text('Заявка $id исчезнет из истории и расписания помещения.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Оставить')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Удалить')),
      ],
    ));
  if (confirmed != true || !context.mounted) return false;
  final error = await context.read<BookingModel>().remove(id);
  if (!context.mounted) return error == null;
  if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  return error == null;
}
