import 'package:flutter/foundation.dart';

import 'room.dart';

/// Shared state survives navigation; field controllers stay in screen State.
class RoomModel extends ChangeNotifier {
  final List<Room> _rooms = [];
  final Set<String> _favoriteIds = {};
  List<Room> get rooms => List.unmodifiable(_rooms);
  List<String> get favoriteIds => List.unmodifiable(_favoriteIds);
  int get favoriteCount => _favoriteIds.length;

  void toggleFavorite(String id) {
    if (!_favoriteIds.remove(id)) _favoriteIds.add(id);
    notifyListeners();
  }
}
