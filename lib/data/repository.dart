import 'result.dart';

abstract class Repository<T> {
  Future<Result<List<T>>> fetchAll();
  Future<Result<T>> fetchById(String id);
  Future<Result<T>> create(T draft);
  Future<Result<T>> update(T item);
  Future<Result<void>> delete(String id);
}
