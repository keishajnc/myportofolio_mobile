import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

const payload = <String, dynamic>{
  'id': 'server-uuid',
  'title': 'Portofolio',
  'description': 'Dibuat dengan Flutter',
  'tech_stack': 'Flutter, Django',
  'project_url': 'https://example.com',
};

void main() {
  test(
    'Project decodes snake_case, defaults missing/null image, omits server id',
    () {
      for (final json in [
        payload,
        {...payload, 'project_image_url': null},
      ]) {
        final project = Project.fromJson(json);
        expect(project.id, 'server-uuid');
        expect(project.techStack, 'Flutter, Django');
        expect(project.projectImageUrl, '');
        expect(
          project.toJson(),
          {...payload}
            ..remove('id')
            ..['project_image_url'] = '',
        );
      }
    },
  );

  test('Public projects use GET without an Authorization header', () async {
    final api = ApiClient(
      baseUrl: 'https://backend.example/',
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://backend.example/api/v1/projects/',
        );
        expect(request.method, 'GET');
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {...payload, 'title': 'Proyek é'},
            ]),
          ),
          200,
        );
      }),
    );
    addTearDown(api.close);
    expect((await api.getProjects()).single.title, 'Proyek é');
  });

  test(
    'Create sends a JSON body without id and with token authentication',
    () async {
      final project = Project.fromJson(payload);
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/projects/');
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], 'Token test-token');
          expect(request.headers['Content-Type'], contains('application/json'));
          expect(jsonDecode(request.body), project.toJson());
          return http.Response(jsonEncode(payload), 201);
        }),
      );
      addTearDown(api.close);
      expect(
        (await api.createProject(project, token: 'test-token')).id,
        'server-uuid',
      );
    },
  );

  test(
    'Login exchanges credentials for token and logout accepts an empty 204',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/token/')) {
            expect(jsonDecode(request.body), {
              'username': 'owner',
              'password': 'password',
            });
            return http.Response('{"token":"abc"}', 200);
          }
          expect(request.url.path, '/api/v1/auth/logout/');
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], 'Token abc');
          return http.Response('', 204);
        }),
      );
      addTearDown(api.close);
      final auth = AuthState(api);
      addTearDown(auth.dispose);
      var notifications = 0;
      auth.addListener(() => notifications++);
      await auth.login('owner', 'password');
      expect(auth.token, 'abc');
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(notifications, 2);
    },
  );

  for (final code in [400, 401, 403, 500]) {
    test('API preserves HTTP $code as a typed failure', () async {
      final api = ApiClient(
        client: MockClient(
          (_) async => http.Response('<html>private debug</html>', code),
        ),
      );
      addTearDown(api.close);
      await expectLater(
        api.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', code),
        ),
      );
      expect(
        apiErrorMessage(ApiException(code, 'private debug')),
        isNot(contains('private debug')),
      );
    });
  }

  for (final failure in [
    const ApiException(500, 'server error'),
    http.ClientException('offline'),
  ]) {
    test(
      'Logout clears local state even after ${failure.runtimeType}',
      () async {
        final api = ApiClient(client: MockClient((_) async => throw failure));
        addTearDown(api.close);
        final auth = AuthState(api, initialToken: 'abc');
        addTearDown(auth.dispose);
        await expectLater(auth.logout(), throwsA(same(failure)));
        expect(auth.token, isNull);
      },
    );
  }

  test('Rejected login does not authenticate; revoked token still logs out locally', () async {
    final api = ApiClient(
      client: MockClient(
        (request) async => http.Response(
          '{}',
          request.url.path.endsWith('/token/') ? 400 : 401,
        ),
      ),
    );
    addTearDown(api.close);
    final auth = AuthState(api);
    addTearDown(auth.dispose);
    await expectLater(
      auth.login('wrong', 'wrong'),
      throwsA(isA<ApiException>()),
    );
    expect(auth.isLoggedIn, isFalse);
    final expired = AuthState(api, initialToken: 'expired');
    addTearDown(expired.dispose);
    await expired.logout();
    expect(expired.isLoggedIn, isFalse);
  });
}
