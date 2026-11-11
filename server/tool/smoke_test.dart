// Supplemental API smoke checks; not the course conformance suite.
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final base = args.isEmpty ? 'http://localhost:8080' : args.first;
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  var passed = 0;
  final suffix = DateTime.now().microsecondsSinceEpoch;
  final email = 'smoke-$suffix@example.test';
  const password = 'Smoke-test-123';

  Future<dynamic> request(String method, String path, int expected,
      {String? token, Object? body, bool binary = false}) async {
    final req = await client.openUrl(method, Uri.parse('$base$path'));
    if (token != null) req.headers.set('Authorization', 'Bearer $token');
    if (body != null) {
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(body));
    }
    final res = await req.close().timeout(const Duration(seconds: 10));
    final bytes =
        await res.fold<List<int>>([], (all, part) => all..addAll(part));
    if (res.statusCode != expected) {
      throw StateError(
          '$method $path: expected $expected, got ${res.statusCode}');
    }
    final value = bytes.isEmpty
        ? null
        : (binary ? bytes : jsonDecode(utf8.decode(bytes)));
    if (expected >= 400 && value['error']['code'] is! String) {
      throw StateError('Missing standard error envelope');
    }
    passed++;
    print('PASS $method $path -> $expected');
    return value;
  }

  void check(bool condition, String label) {
    if (!condition) throw StateError(label);
    passed++;
    print('PASS $label');
  }

  try {
    final health = await request('GET', '/health', 200);
    check(health['status'] == 'ok', 'health status');
    await request('GET', '/notes', 401);
    final credentials = {'email': email, 'password': password, 'name': 'Smoke'};
    final registration =
        await request('POST', '/auth/register', 201, body: credentials);
    final token = registration['token'] as String;
    await request('POST', '/auth/register', 409, body: credentials);
    await request('POST', '/auth/login', 401,
        body: {'email': email, 'password': 'wrong'});
    await request('POST', '/auth/login', 200, body: credentials);
    final me = await request('GET', '/me', 200, token: token);
    check(me['email'] == email, 'authenticated user');
    await request('POST', '/notes', 400, token: token, body: {'title': ''});
    final note = await request('POST', '/notes', 201,
        token: token,
        body: {'title': 'Покупки $suffix', 'content': 'молоко, хлеб'});
    final id = note['id'];
    check(id is int, 'server-generated numeric ID');
    await request('GET', '/notes/$id', 200, token: token);
    final list = await request(
        'GET',
        '/notes?page=1&limit=1&search=${Uri.encodeQueryComponent('Покупки')}',
        200,
        token: token);
    check(
        list['total'] == 1 &&
            list['page'] == 1 &&
            list['limit'] == 1 &&
            list['items'].length == 1,
        'pagination envelope and Cyrillic server search');
    final empty =
        await request('GET', '/notes?page=2&limit=1', 200, token: token);
    check(empty['items'].isEmpty && empty['total'] == 1, 'second page');
    final other = await request('POST', '/auth/register', 201, body: {
      'email': 'other-$suffix@example.test',
      'password': password,
      'name': 'Other'
    });
    await request('GET', '/notes/$id', 404, token: other['token']);
    final updated = await request('PUT', '/notes/$id', 200,
        token: token, body: {'title': 'Updated', 'content': 'Test'});
    check(updated['title'] == 'Updated', 'updated title');
    await request('DELETE', '/notes/$id', 204, token: token);
    await request('GET', '/notes/$id', 404, token: token);
    await request('DELETE', '/notes/$id', 404, token: token);
    await request('GET', '/notes', 401, token: 'invalid-token');
    print('SMOKE PASS: $passed checks. This is NOT conformance 37/37.');
  } finally {
    client.close(force: true);
  }
}
