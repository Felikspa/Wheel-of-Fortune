import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wheel_of_fortune/l10n/app_localizations.dart';
import 'package:wheel_of_fortune/src/data/in_memory_wheel_repository.dart';
import 'package:wheel_of_fortune/src/services/i18n_service.dart';
import 'package:wheel_of_fortune/src/state/app_controller.dart';
import 'package:wheel_of_fortune/src/ui/app_theme.dart';
import 'package:wheel_of_fortune/src/ui/home_shell.dart';
import 'package:wheel_of_fortune/src/ui/modes/mode_visuals.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<AppController>(
          builder: (context, app, _) {
            final locale = I18nService.resolveLocale(
              systemLocale: const Locale('en'),
              overrideCode: app.settings.localeOverride,
            );
            return MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('zh')],
              theme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
              home: const HomeShell(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDrawer(WidgetTester tester) async {
    final scaffoldState = tester.state<ScaffoldState>(
      find.byType(Scaffold).first,
    );
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();
  }

  Future<void> switchMode(WidgetTester tester, String targetModeLabel) async {
    await openDrawer(tester);
    await tester.tap(find.text('Mode: Wheel').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(targetModeLabel).last);
    await tester.pumpAndSettle();
  }

  testWidgets('supports horizontal navigation to manage page', (tester) async {
    await pumpApp(tester);

    expect(find.text('Spin'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Wheels'), findsOneWidget);
  });

  testWidgets('locks horizontal paging while spinning', (tester) async {
    await pumpApp(tester);

    expect(find.text('Spin'), findsOneWidget);
    await tester.tap(find.text('Spin'));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Wheels'), findsNothing);
  });

  testWidgets('drawer mode dropdown switches to coin mode and closes drawer', (
    tester,
  ) async {
    await pumpApp(tester);

    await switchMode(tester, 'Mode: Coin');
    expect(find.text('Toss Coin'), findsOneWidget);
    final scaffoldState = tester.state<ScaffoldState>(
      find.byType(Scaffold).first,
    );
    expect(scaffoldState.isDrawerOpen, isFalse);
  });

  testWidgets('dice mode roll button is disabled when mapping is incomplete', (
    tester,
  ) async {
    await pumpApp(tester);

    await switchMode(tester, 'Mode: Dice');
    final button = tester.widget<DrawModeGlassActionButton>(
      find.ancestor(
        of: find.text('Roll Dice'),
        matching: find.byType(DrawModeGlassActionButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('card mode requires shuffle before reveal', (tester) async {
    await pumpApp(tester);

    await switchMode(tester, 'Mode: Card');
    expect(find.text('No result yet'), findsOneWidget);
    await tester.tap(find.text('Option A').first);
    await tester.pumpAndSettle();
    expect(find.text('No result yet'), findsOneWidget);

    await tester.tap(find.text('Shuffle'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.style_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('No result yet'), findsNothing);
  });
}
