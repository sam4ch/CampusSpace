import '../data/room_repository.dart';
import 'collection_model.dart';
import 'room.dart';

/// Shared state survives navigation; field controllers stay in screen State.
class RoomModel extends CollectionModel<Room> {
  RoomModel(RoomRepository super.repository);
  @override
  String idOf(Room item) => item.id;
  List<Room> get rooms => items;
  List<Room> get favorites =>
      List.unmodifiable(items.where((room) => room.isFavorite));
  int get favoriteCount => favorites.length;

  Future<String?> toggleFavorite(String id) async {
    final room = byId(id);
    if (room == null) return 'Помещение не существует';
    return update(room.copyWith(isFavorite: !room.isFavorite));
  }
}
