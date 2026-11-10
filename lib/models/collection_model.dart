import 'package:flutter/foundation.dart';

import '../data/repository.dart';
import '../data/result.dart';

/// No widgets and no mock dependency: the same model can use an HTTP repository.
abstract class CollectionModel<T> extends ChangeNotifier {
  CollectionModel(this._repository);
  final Repository<T> _repository;
  List<T> _items = [];
  bool _loading = false;
  bool _saving = false;
  bool _disposed = false;
  String? _error;
  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;
  String idOf(T item);
  T? byId(String id) {
    for (final item in _items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  Future<void> load() async {
    if (_loading || _saving || _disposed) return;
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.fetchAll();
    if (_disposed) return;
    switch (result) {
      case Ok(:final value): _items = List.of(value);
      case Err(:final msg): _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> add(T draft) => _write(() async {
    switch (await _repository.create(draft)) {
      case Ok(:final value): _items = [value, ..._items]; return null;
      case Err(:final msg): return msg;
    }
  });

  Future<String?> update(T item) => _write(() async {
    switch (await _repository.update(item)) {
      case Ok(:final value):
        _items = [for (final old in _items) if (idOf(old) == idOf(value)) value else old];
        return null;
      case Err(:final msg): return msg;
    }
  });

  Future<String?> remove(String id) => _write(() async {
    switch (await _repository.delete(id)) {
      case Ok(): _items = _items.where((item) => idOf(item) != id).toList(); return null;
      case Err(:final msg): return msg;
    }
  });

  Future<String?> _write(Future<String?> Function() action) async {
    if (_disposed) return 'Экран закрыт';
    if (_saving || _loading) return 'Дождитесь завершения текущего запроса';
    _saving = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
