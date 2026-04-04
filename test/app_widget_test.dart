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
}
