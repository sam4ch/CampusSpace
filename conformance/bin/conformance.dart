// Independently authored CampusSpace suite. Not the instructor's missing kit.
import 'dart:convert';
import 'dart:io';

class Reply {
  Reply(this.status, this.headers, this.bytes);
  final int status;
  final Map<String, String> headers;
  final List<int> bytes;
  dynamic get json => jsonDecode(utf8.decode(bytes));
}

void require(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void status(Reply r, int expected) =>
    require(r.status == expected, 'Expected HTTP $expected, got ${r.status}');

Map<String, dynamic> jsonObject(Reply r, int expected) {
  status(r, expected);
  require(r.headers['content-type']?.contains('application/json') ?? false,
      'Expected JSON Content-Type');
  return r.json as Map<String, dynamic>;
}

void error(Reply r, int expected, String code) {
  final e = jsonObject(r, expected)['error'] as Map<String, dynamic>;
  require(e['code'] == code, 'Expected error code $code');
  require(e['message'] is String && (e['message'] as String).isNotEmpty,
      'Error message is missing');
}

void user(Map<String, dynamic> u, String email) {
  require(u['id'] is int && u['id'] > 0, 'User ID');
  require(u['email'] == email && u['name'] is String, 'User fields');
  require(!u.containsKey('password') && !u.containsKey('password_hash'),
      'Password data exposed');
}

void note(Map<String, dynamic> n, String title, String content) {
  require(n['id'] is int && n['id'] > 0, 'Note ID');
  require(n['title'] == title && n['content'] == content, 'Note fields');
  require(DateTime.tryParse(n['createdAt'] as String) != null, 'createdAt');
}

List<dynamic> page(Reply r, int p, int limit, int total) {
  final j = jsonObject(r, 200);
  require(j['page'] == p && j['limit'] == limit && j['total'] == total,
      'Pagination metadata');
  return j['items'] as List<dynamic>;
}

Future<void> main(List<String> args) async {
  var base = 'http://localhost:8080';
  String? report;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--base-url' && i + 1 < args.length) {
      base = args[++i];
    } else if (args[i] == '--json-output' && i + 1 < args.length) {
      report = args[++i];
    } else {
      stderr.writeln('Usage: dart run bin/conformance.dart '
          '[--base-url http://localhost:8080] [--json-output results.json]');
      exitCode = 64;
      return;
    }
  }
  final origin = Uri.parse(base);
  if (!['http', 'https'].contains(origin.scheme) || origin.host.isEmpty) {
    stderr.writeln('Invalid base URL');
    exitCode = 64;
    return;
  }
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
  final results = <Map<String, Object?>>[];
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final email = 'contract-$stamp@example.test';
  final otherEmail = 'other-$stamp@example.test';
  const password = 'Contract-123';
  var token = '', otherToken = '';
  var id = -1, secondId = -1, fileId = -1;
  const payload = [0, 1, 2, 127, 128, 255, 13, 10];

  Future<Reply> send(String method, String path,
      {String? bearer, Object? body, List<int>? raw, String? type}) {
    return (() async {
      final req = await client.openUrl(method, origin.resolve(path));
      if (bearer != null) req.headers.set('Authorization', 'Bearer $bearer');
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.add(utf8.encode(jsonEncode(body)));
      } else if (raw != null) {
        req.headers.set('Content-Type', type ?? 'application/json');
        req.contentLength = raw.length;
        req.add(raw);
      }
      final res = await req.close();
      final bytes =
          await res.fold<List<int>>([], (all, part) => all..addAll(part));
      final headers = <String, String>{};
      res.headers.forEach((key, value) => headers[key] = value.join(','));
      return Reply(res.statusCode, headers, bytes);
    })()
        .timeout(const Duration(seconds: 10));
  }

  Future<void> test(String name, Future<void> Function() run) async {
    try {
      await run();
      results.add({'name': name, 'passed': true});
      print('PASS ${results.length.toString().padLeft(2, '0')} $name');
    } catch (e) {
      // Never print response bodies or bearer tokens.
      results.add(
          {'name': name, 'passed': false, 'error': e.runtimeType.toString()});
      print(
          'FAIL ${results.length.toString().padLeft(2, '0')} $name: ${e.runtimeType}');
      if (e is StateError) print('  ${e.message}');
    }
  }

  List<int> multipart(String field, List<int> data) => [
        ...utf8.encode('--pam-boundary\r\nContent-Disposition: form-data; '
            'name="$field"; filename="contract.bin"\r\n'
            'Content-Type: application/octet-stream\r\n\r\n'),
        ...data,
        ...utf8.encode('\r\n--pam-boundary--\r\n'),
      ];
  const multiType = 'multipart/form-data; boundary=pam-boundary';
  final credentials = {
    'email': email,
    'password': password,
    'name': 'Contract'
  };

  print('CampusSpace independently authored API suite v1.0');
  print('Target: $base; creates isolated test users and files.');
  try {
    await test('Health', () async {
      require(jsonObject(await send('GET', '/health'), 200)['status'] == 'ok',
          'health');
    });
    await test('CORS preflight', () async {
      final r = await send('OPTIONS', '/notes');
      status(r, 200);
      require(r.headers['access-control-allow-origin'] == '*', 'CORS origin');
      require(
          r.headers['access-control-allow-headers']!
              .toLowerCase()
              .contains('authorization'),
          'CORS auth');
      require(r.headers['access-control-allow-methods']!.contains('DELETE'),
          'CORS methods');
    });
    await test('Notes require auth',
        () async => error(await send('GET', '/notes'), 401, 'UNAUTHORIZED'));
    await test(
        'Invalid token',
        () async => error(await send('GET', '/notes', bearer: 'invalid'), 401,
            'UNAUTHORIZED'));
    await test('Register user', () async {
      final j = jsonObject(
          await send('POST', '/auth/register', body: credentials), 201);
      user(j['user'], email);
      token = j['token'] as String;
      require(token.split('.').length == 3, 'JWT structure');
    });
    await test(
        'Registration validates name',
        () async => error(
            await send('POST', '/auth/register',
                body: {'email': 'missing-$email', 'password': password}),
            400,
            'VALIDATION_ERROR'));
    await test(
        'Duplicate email',
        () async => error(
            await send('POST', '/auth/register', body: credentials),
            409,
            'EMAIL_TAKEN'));
    await test(
        'Incorrect password',
        () async => error(
            await send('POST', '/auth/login',
                body: {'email': email, 'password': 'wrong'}),
            401,
            'UNAUTHORIZED'));
    await test('Login', () async {
      final j =
          jsonObject(await send('POST', '/auth/login', body: credentials), 200);
      user(j['user'], email);
      token = j['token'] as String;
      require(token.split('.').length == 3, 'JWT structure');
    });
    await test(
        'Authenticated profile',
        () async => user(
            jsonObject(await send('GET', '/me', bearer: token), 200), email));
    await test('Profile requires auth',
        () async => error(await send('GET', '/me'), 401, 'UNAUTHORIZED'));
    await test(
        'New user empty list',
        () async => require(
            page(await send('GET', '/notes', bearer: token), 1, 20, 0).isEmpty,
            'Expected empty list'));
    await test('Create note', () async {
      final j = jsonObject(
          await send('POST', '/notes',
              bearer: token, body: {'title': 'Покупки', 'content': 'молоко'}),
          201);
      note(j, 'Покупки', 'молоко');
      id = j['id'];
    });
    await test(
        'Read note',
        () async => note(
            jsonObject(await send('GET', '/notes/$id', bearer: token), 200),
            'Покупки',
            'молоко'));
    await test('Create another note, default content', () async {
      final j = jsonObject(
          await send('POST', '/notes',
              bearer: token, body: {'title': 'Second'}),
          201);
      note(j, 'Second', '');
      secondId = j['id'];
      require(secondId != id, 'Unique IDs');
    });
    await test('Distinct pages in descending ID order', () async {
      final a = page(
          await send('GET', '/notes?page=1&limit=1', bearer: token), 1, 1, 2);
      final b = page(
          await send('GET', '/notes?page=2&limit=1', bearer: token), 2, 1, 2);
      require(
          a.length == 1 &&
              b.length == 1 &&
              a.first['id'] == secondId &&
              b.first['id'] == id,
          'Page contents');
    });
    await test('Cyrillic title search', () async {
      final a = page(
          await send(
              'GET', '/notes?search=${Uri.encodeQueryComponent('Покуп')}',
              bearer: token),
          1,
          20,
          1);
      require(a.length == 1 && a.first['id'] == id, 'Title search');
    });
    await test('Content search', () async {
      final a = page(
          await send(
              'GET', '/notes?search=${Uri.encodeQueryComponent('молоко')}',
              bearer: token),
          1,
          20,
          1);
      require(a.length == 1 && a.first['id'] == id, 'Content search');
    });
    await test(
        'Search without matches',
        () async => require(
            page(
                    await send('GET', '/notes?search=absent-$stamp',
                        bearer: token),
                    1,
                    20,
                    0)
                .isEmpty,
            'Empty search'));
    await test('Update persisted note', () async {
      note(
          jsonObject(
              await send('PUT', '/notes/$id',
                  bearer: token,
                  body: {'title': 'Updated', 'content': 'Changed'}),
              200),
          'Updated',
          'Changed');
      note(jsonObject(await send('GET', '/notes/$id', bearer: token), 200),
          'Updated', 'Changed');
    });
    await test(
        'Invalid create',
        () async => error(
            await send('POST', '/notes', bearer: token, body: {'title': ' '}),
            400,
            'VALIDATION_ERROR'));
    await test('Invalid update preserves data', () async {
      error(await send('PUT', '/notes/$id', bearer: token, body: {}), 400,
          'VALIDATION_ERROR');
      note(jsonObject(await send('GET', '/notes/$id', bearer: token), 200),
          'Updated', 'Changed');
    });
    await test(
        'Malformed JSON',
        () async => error(
            await send('POST', '/notes', bearer: token, raw: utf8.encode('{')),
            400,
            'VALIDATION_ERROR'));
    await test(
        'Missing note',
        () async => error(
            await send('GET', '/notes/0', bearer: token), 404, 'NOT_FOUND'));
    await test('Second user has isolated list', () async {
      final j = jsonObject(
          await send('POST', '/auth/register', body: {
            'email': otherEmail,
            'password': password,
            'name': 'Other'
          }),
          201);
      user(j['user'], otherEmail);
      otherToken = j['token'];
      require(
          page(await send('GET', '/notes', bearer: otherToken), 1, 20, 0)
              .isEmpty,
          'Other user list');
    });
    await test(
        'Foreign GET is 404',
        () async => error(await send('GET', '/notes/$id', bearer: otherToken),
            404, 'NOT_FOUND'));
    await test(
        'Foreign PUT is 404',
        () async => error(
            await send('PUT', '/notes/$id',
                bearer: otherToken, body: {'title': 'Stolen'}),
            404,
            'NOT_FOUND'));
    await test(
        'Foreign DELETE is 404',
        () async => error(
            await send('DELETE', '/notes/$id', bearer: otherToken),
            404,
            'NOT_FOUND'));
    await test('Delete returns empty 204', () async {
      final r = await send('DELETE', '/notes/$id', bearer: token);
      status(r, 204);
      require(r.bytes.isEmpty, '204 body');
    });
    await test('Deleted note stays absent', () async {
      error(await send('GET', '/notes/$id', bearer: token), 404, 'NOT_FOUND');
      error(
          await send('DELETE', '/notes/$id', bearer: token), 404, 'NOT_FOUND');
      status(await send('DELETE', '/notes/$secondId', bearer: token), 204);
      require(
          page(await send('GET', '/notes', bearer: token), 1, 20, 0).isEmpty,
          'Empty after deletion');
    });
    await test(
        'Upload requires auth',
        () async => error(
            await send('POST', '/files',
                raw: multipart('file', payload), type: multiType),
            401,
            'UNAUTHORIZED'));
    await test('Multipart upload metadata', () async {
      final j = jsonObject(
          await send('POST', '/files',
              bearer: token, raw: multipart('file', payload), type: multiType),
          201);
      require(j['id'] is int && j['id'] > 0, 'File ID');
      fileId = j['id'];
      require(
          j['url'] == '/files/$fileId' &&
              j['name'] == 'contract.bin' &&
              j['size'] == payload.length &&
              j['mimeType'] == 'application/octet-stream',
          'File metadata');
    });
    await test('Public download bytes and protective headers', () async {
      final r = await send('GET', '/files/$fileId');
      status(r, 200);
      require(base64Encode(r.bytes) == base64Encode(payload), 'File bytes');
      require(
          r.headers['content-type'] == 'application/octet-stream' &&
              r.headers['content-length'] == '${payload.length}',
          'Download metadata');
      require(
          r.headers['content-disposition'] == 'attachment' &&
              r.headers['x-content-type-options'] == 'nosniff' &&
              r.headers['content-security-policy']!.contains('sandbox'),
          'Download protection');
    });
    await test('Missing file',
        () async => error(await send('GET', '/files/0'), 404, 'NOT_FOUND'));
    await test(
        'Missing multipart field',
        () async => error(
            await send('POST', '/files',
                bearer: token,
                raw: multipart('wrong', payload),
                type: multiType),
            400,
            'VALIDATION_ERROR'));
    await test(
        'Malformed multipart',
        () async => error(
            await send('POST', '/files',
                bearer: token,
                raw: utf8.encode('--pam-boundary\r\nBroken header'),
                type: multiType),
            400,
            'VALIDATION_ERROR'));
    await test(
        'Upload over 5 MiB rejected',
        () async => error(
            await send('POST', '/files',
                bearer: token,
                raw: multipart('file', List.filled(5 * 1024 * 1024 + 1, 65)),
                type: multiType),
            400,
            'VALIDATION_ERROR'));
  } finally {
    client.close(force: true);
  }
  final passed = results.where((r) => r['passed'] == true).length;
  print(
      '${passed == results.length ? 'PASS' : 'FAIL'} — $passed/${results.length} checks passed (CampusSpace custom suite)');
  if (report != null) {
    await File(report)
        .writeAsString(const JsonEncoder.withIndent('  ').convert({
      'suite': 'CampusSpace custom conformance',
      'version': '1.0.0',
      'officialCourseSuite': false,
      'baseUrl': base,
      'timestampUtc': DateTime.now().toUtc().toIso8601String(),
      'passed': passed,
      'total': results.length,
      'results': results,
    }));
  }
  if (passed != results.length || results.length != 37) exitCode = 1;
}
