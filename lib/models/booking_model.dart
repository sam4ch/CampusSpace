import '../data/booking_repository.dart';
import 'booking.dart';
import 'collection_model.dart';

class BookingModel extends CollectionModel<Booking> {
  BookingModel(BookingRepository super.repository);
  @override
  String idOf(Booking item) => item.id;
  List<Booking> get bookings => items;
  int get activeCount => items.where((booking) => booking.isActive).length;
  Future<String?> cancel(String id) async {
    final booking = byId(id);
    if (booking == null) return 'Заявка не существует';
    if (!booking.isActive) return 'Можно отменить только активную заявку';
    return update(booking.copyWith(status: BookingStatus.cancelled));
  }
}
