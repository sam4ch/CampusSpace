import 'mock_settings.dart';
import 'repository.dart';
import 'result.dart';

/// Shared CRUD mechanics; subclasses supply identity and domain rules.
abstract class MockRepository<T> implements Repository<T> {
  MockRepository(this.settings, List<T> seed) : _items = List.of(seed);
  final MockSettings settings;
  final List<T> _items;
  int _nextId = 2000;
  String idOf(T item);
  T withId(T draft, String id);
  String get idPrefix;
  String get missingMessage;
  List<T> get snapshot => List.unmodifiable(_items);

  Future<String?> validate(T item) async => null;

  @override
  Future<Result<List<T>>> fetchAll() async {
    if (await settings.fails()) return const Err(MockSettings.networkError);
    return Ok(List.of(_items)); // Never hand out internal storage.
  }

  @override
  Future<Result<T>> fetchById(String id) async {
    if (await settings.fails()) return const Err(MockSettings.networkError);
    for (final item in _items) {
      if (idOf(item) == id) return Ok(item);
    }
    return Err(missingMessage);
  }

  @override
  Future<Result<T>> create(T draft) async {
    if (await settings.fails()) return const Err(MockSettings.networkError);
    final error = await validate(draft);
    if (error != null) return Err(error);
    String id;
    do {
      id = '$idPrefix${_nextId++}';
    } while (_items.any((item) => idOf(item) == id));
    final created = withId(draft, id); // Storage assigns identity.
    _items.add(created);
    return Ok(created);
  }

  @override
  Future<Result<T>> update(T item) async {
    if (await settings.fails()) return const Err(MockSettings.networkError);
    final error = await validate(item);
    if (error != null) return Err(error);
    final index = _items.indexWhere((old) => idOf(old) == idOf(item));
    if (index < 0) return Err(missingMessage);
    _items[index] = item;
    return Ok(item);
  }

  @override
  Future<Result<void>> delete(String id) async {
    if (await settings.fails()) return const Err(MockSettings.networkError);
    final index = _items.indexWhere((item) => idOf(item) == id);
    if (index < 0) return Err(missingMessage);
    _items.removeAt(index);
    return const Ok(null);
  }
}
