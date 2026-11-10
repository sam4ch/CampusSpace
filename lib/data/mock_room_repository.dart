import '../models/room.dart';
import 'mock_data.dart';
import 'mock_repository.dart';
import 'mock_settings.dart';
import 'room_repository.dart';

class MockRoomRepository extends MockRepository<Room> implements RoomRepository {
  MockRoomRepository(MockSettings settings, {List<Room>? seed})
    : super(settings, seed ?? [
        for (final room in MockData.rooms)
          room.copyWith(isFavorite: MockData.favoriteRoomIds.contains(room.id)),
      ]);
  @override
  String idOf(Room item) => item.id;
  @override
  Room withId(Room draft, String id) => draft.copyWith(id: id);
  @override
  String get idPrefix => 'r';
  @override
  String get missingMessage => 'Помещение не существует';
}
