class Room {
  const Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.type,
    required this.capacity,
    required List<String> equipment,
    required this.description,
    required this.hours,
    this.isFavorite = false,
  }) : _equipment = equipment;

  final String id;
  final String name;
  final String building;
  final int floor;
  final String type;
  final int capacity;
  final List<String> _equipment;
  List<String> get equipment => List.unmodifiable(_equipment);
  final String description;
  final String hours;
  final bool isFavorite;

  Room copyWith({String? id, bool? isFavorite}) => Room(
    id: id ?? this.id, name: name, building: building, floor: floor,
    type: type, capacity: capacity, equipment: equipment,
    description: description, hours: hours,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
