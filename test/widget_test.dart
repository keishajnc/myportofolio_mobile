import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const projectJson = {
  'id': 'server-uuid',
  'title': 'Portfolio Flutter',
  'description': 'Portofolio pribadi',
  'tech_stack': 'Flutter, Django',
  'project_url': 'https://example.com/project',
  'project_image_url': '',
};

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> tapText(WidgetTester tester, String text) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester) async {
  await tester.enterText(field('Username'), 'owner');
  await tester.enterText(field('Password'), 'test-password');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

Future<void> fillProject(WidgetTester tester) async {
  for (final entry in {
    'Title': projectJson['title']!,
    'Description': projectJson['description']!,
    'Tech Stack': projectJson['tech_stack']!,
    'Project URL': projectJson['project_url']!,
  }.entries) {
    await tester.ensureVisible(field(entry.key));
    await tester.enterText(field(entry.key), entry.value);
  }
}

Future<void> pumpScreen(
  WidgetTester tester,
  ApiClient api,
  Widget screen, {
  String? token,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider(
          create: (_) => AuthState(api, initialToken: token),
        ),
      ],
      child: MaterialApp(home: screen),
    ),
  );
}

ApiClient mockApi(Future<http.Response> Function(http.Request) handler) {
  final api = ApiClient(client: MockClient(handler));
  addTearDown(api.close);
  return api;
}

Future<http.Response> successfulServer(http.Request request) async {
  if (request.url.path.endsWith('/token/')) {
    return http.Response('{"token":"valid-token"}', 200);
  }
  if (request.url.path.endsWith('/logout/')) return http.Response('', 204);
  if (request.method == 'POST') {
    return http.Response(
      jsonEncode({
        ...jsonDecode(request.body) as Map<String, dynamic>,
        'id': 'server-uuid',
      }),
      201,
    );
  }
  return http.Response(jsonEncode([projectJson]), 200);
}

void main() {
  testWidgets('Home preserves identity on a narrow mobile screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MyApp(apiClient: mockApi(successfulServer)));
    for (final text in [
      '2506551232',
      'Keisha Janice Maulina Napitupulu',
      'PBP A',
      'Lihat Proyek',
      'Tambah Proyek',
      'Login',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Guest add requires login; cancelling stays on Home', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: mockApi(successfulServer)));
    await tapText(tester, 'Tambah Proyek');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets(
    'Login opens protected form; Save posts once and shows server data',
    (tester) async {
      var creates = 0;
      final api = mockApi((request) async {
        if (request.url.path == '/api/v1/projects/' &&
            request.method == 'POST') {
          creates++;
          expect(request.headers['Authorization'], 'Token valid-token');
        }
        return successfulServer(request);
      });
      await tester.pumpWidget(MyApp(apiClient: api));
      await tapText(tester, 'Tambah Proyek');
      await login(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await fillProject(tester);
      await tapText(tester, 'Save');
      expect(creates, 1);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Tech Stack: Flutter, Django'), findsOneWidget);
      await tapText(tester, 'OK');
      expect(
        tester.widget<TextField>(field('Title')).controller!.text,
        isEmpty,
      );
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('Invalid login shows status and never opens the protected form', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        apiClient: mockApi(
          (_) async =>
              http.Response('{"non_field_errors":["bad credentials"]}', 400),
        ),
      ),
    );
    await tapText(tester, 'Tambah Proyek');
    await login(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(find.textContaining('(400)'), findsOneWidget);
  });

  testWidgets('Required fields and URL validation prevent any POST', (
    tester,
  ) async {
    var calls = 0;
    final api = mockApi((request) async {
      calls++;
      return successfulServer(request);
    });
    await pumpScreen(
      tester,
      api,
      const ProjectFormPage(),
      token: 'valid-token',
    );
    await tapText(tester, 'Save');
    expect(find.text('Isian ini tidak boleh kosong!'), findsNWidgets(3));
    expect(calls, 0);
    await fillProject(tester);
    await tester.enterText(field('Project URL'), 'javascript:alert(1)');
    await tapText(tester, 'Save');
    expect(
      find.text('Masukkan URL lengkap dengan http:// atau https://.'),
      findsOneWidget,
    );
    expect(calls, 0);
  });

  testWidgets('403 preserves the form and does not report a successful save', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      mockApi((_) async => http.Response('{}', 403)),
      const ProjectFormPage(),
      token: 'visitor',
    );
    await fillProject(tester);
    await tapText(tester, 'Save');
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('(403)'), findsOneWidget);
    expect(
      tester.widget<TextField>(field('Title')).controller!.text,
      projectJson['title'],
    );
  });

  testWidgets(
    '401 requests login again, preserving input for a successful retry',
    (tester) async {
      var creates = 0;
      final api = mockApi((request) async {
        if (request.url.path == '/api/v1/projects/' &&
            request.method == 'POST' &&
            creates++ == 0) {
          return http.Response('{}', 401);
        }
        return successfulServer(request);
      });
      await pumpScreen(tester, api, const ProjectFormPage(), token: 'expired');
      await fillProject(tester);
      await tapText(tester, 'Save');
      expect(find.byType(LoginScreen), findsOneWidget);
      await login(tester);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('Title')).controller!.text,
        projectJson['title'],
      );
      await tapText(tester, 'Save');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(creates, 2);
    },
  );

  testWidgets(
    'Public list shows real projects and opens a detail without an empty image',
    (tester) async {
      var gets = 0;
      final api = mockApi((request) async {
        gets++;
        return successfulServer(request);
      });
      await pumpScreen(tester, api, const ProjectListScreen());
      await tester.pumpAndSettle();
      expect(find.text('Flutter, Django'), findsOneWidget);
      expect(gets, 1);
      await tapText(tester, 'Portfolio Flutter');
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('https://example.com/project'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(gets, 1);
    },
  );

  testWidgets('Empty list supports pull-to-refresh', (tester) async {
    var gets = 0;
    final api = mockApi((_) async {
      gets++;
      return http.Response('[]', 200);
    });
    await pumpScreen(tester, api, const ProjectListScreen());
    await tester.pumpAndSettle();
    expect(find.text('Belum ada proyek.'), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(gets, 2);
  });

  testWidgets('List loading and failure have a working retry', (tester) async {
    final pending = Completer<http.Response>();
    var gets = 0;
    final api = mockApi(
      (_) async => gets++ == 0
          ? pending.future
          : http.Response(jsonEncode([projectJson]), 200),
    );
    await pumpScreen(tester, api, const ProjectListScreen());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(http.Response('<html>private debug</html>', 500));
    await tester.pumpAndSettle();
    expect(find.textContaining('private debug'), findsNothing);
    await tapText(tester, 'Coba Lagi');
    expect(find.text('Portfolio Flutter'), findsOneWidget);
  });

  testWidgets(
    'Drawer guards Add Project and can replace the route after login',
    (tester) async {
      await tester.pumpWidget(MyApp(apiClient: mockApi(successfulServer)));
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Add Project');
      expect(find.byType(LoginScreen), findsOneWidget);
      await login(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
        isFalse,
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Home');
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      await tapText(tester, 'Logout');
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Berhasil logout.'), findsOneWidget);
    },
  );
}
