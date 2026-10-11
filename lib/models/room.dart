class Room {
  const Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.type,
    required this.capacity,
    required this.equipment,
    required this.description,
    required this.hours,
  });

  final String id;
  final String name;
  final String building;
  final int floor;
  final String type;
  final int capacity;
  final List<String> equipment;
  final String description;
  final String hours;
}
