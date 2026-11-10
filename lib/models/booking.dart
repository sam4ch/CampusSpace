enum BookingStatus { pending, approved, rejected, cancelled, completed }

class Booking {
  const Booking({
    required this.id,
    required this.roomId,
    required this.date,
    required this.time,
    required this.participants,
    required this.purpose,
    required this.status,
  });

  final String id;
  final String roomId;
  final String date;
  final String time;
  final int participants;
  final String purpose;
  final BookingStatus status;

  bool get isActive => status == BookingStatus.pending || status == BookingStatus.approved;

  Booking copyWith({String? id, BookingStatus? status, String? date}) => Booking(
    id: id ?? this.id, roomId: roomId, date: date ?? this.date, time: time,
    participants: participants, purpose: purpose, status: status ?? this.status,
  );
}
