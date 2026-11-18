import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home keeps identity and action cards on a mobile screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506551232'), findsOneWidget);
    expect(find.text('Keisha Janice Maulina Napitupulu'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add card pushes a form and system Back returns home', (
    tester,
  ) async {
    await openForm(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isTrue,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Drawer replaces routes in both directions', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('My Portfolio'), findsOneWidget);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isFalse,
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(MyHomePage))).canPop(),
      isFalse,
    );
  });

  for (final input in ['', '   ']) {
    testWidgets(
      'Rejects ${input.isEmpty ? 'empty' : 'whitespace'} required fields',
      (tester) async {
        await openForm(tester);
        await tester.enterText(field('Nama Proyek'), input);
        await tester.enterText(field('Deskripsi Proyek'), input);
        await save(tester);
        expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
        expect(
          find.text('Deskripsi proyek tidak boleh kosong!'),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }

  testWidgets(
    'Dialog shows all inputs; OK clears text, category, and saved data',
    (tester) async {
      await openForm(tester);
      await tester.enterText(field('Nama Proyek'), 'Portfolio Flutter');
      await tester.enterText(
        field('Deskripsi Proyek'),
        'Aplikasi portofolio saya',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      for (final category in [
        'Web Development',
        'Mobile Development',
        'Machine Learning',
        'Data Science',
        'Other',
      ]) {
        expect(find.text(category), findsWidgets);
      }
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        field('Teknologi yang Digunakan'),
        'Flutter, Django',
      );
      await tester.enterText(
        field('Tautan Proyek'),
        'https://example.com/portfolio',
      );
      await save(tester);

      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Portfolio Flutter'), findsOneWidget);
      expect(find.text('Deskripsi: Aplikasi portofolio saya'), findsOneWidget);
      expect(find.text('Kategori: Mobile Development'), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
      expect(
        find.text('Tautan: https://example.com/portfolio'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.controller.text, isEmpty);
      }
      final dropdown = tester.state<FormFieldState<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdown.value, 'Web Development');

      await tester.ensureVisible(field('Nama Proyek'));
      await tester.enterText(field('Nama Proyek'), 'Proyek kedua');
      await tester.enterText(field('Deskripsi Proyek'), 'Tanpa isian opsional');
      await save(tester);
      expect(find.text('Nama Proyek: Proyek kedua'), findsOneWidget);
      expect(find.text('Kategori: Web Development'), findsOneWidget);
      expect(find.text('Teknologi: '), findsOneWidget);
      expect(find.text('Tautan: '), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Django'), findsNothing);
    },
  );

  testWidgets('Other action cards retain their SnackBar behavior', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    for (final name in ['Lihat Proyek', 'Logout']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
      expect(find.byType(MyHomePage), findsOneWidget);
    }
  });

  testWidgets('Form and long dialog scroll on a small screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openForm(tester);
    await tester.enterText(field('Nama Proyek'), 'Proyek panjang');
    await tester.enterText(
      field('Deskripsi Proyek'),
      'Deskripsi panjang. ' * 100,
    );
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
