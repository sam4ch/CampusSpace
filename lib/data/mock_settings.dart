/// Demo-only controls shared by mock repositories. Removed together on L5.
class MockSettings {
  MockSettings({this.latency = const Duration(milliseconds: 800)});
  Duration latency;
  bool simulateError = false;
  static const networkError = 'Сервер не отвечает — повторите попытку';

  Future<bool> fails() async {
    await Future<void>.delayed(latency);
    return simulateError;
  }
}
