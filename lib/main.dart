import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'src/data/isar_wheel_repository.dart';
import 'src/services/i18n_service.dart';
import 'src/state/app_controller.dart';
import 'src/ui/app_theme.dart';
import 'src/ui/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  final controller = AppController(repository: IsarWheelRepository());
  await controller.initialize();
  runApp(WheelOfFortuneApp(controller: controller));
}

class WheelOfFortuneApp extends StatelessWidget {
  const WheelOfFortuneApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppController>.value(
      value: controller,
      child: Consumer<AppController>(
        builder: (context, app, _) {
          final locale = I18nService.resolveLocale(
            systemLocale: WidgetsBinding.instance.platformDispatcher.locale,
            overrideCode: app.settings.localeOverride,
          );
          return MaterialApp(
            title: 'Wheel of Fortune',
            locale: locale,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('zh')],
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: toFlutterThemeMode(app.settings.themeMode),
            home: app.loading
                ? Scaffold(
                    body: Center(
                      child: Text(
                        AppLocalizations.of(context)?.loading ?? 'Loading...',
                      ),
                    ),
                  )
                : const HomeShell(),
          );
        },
      ),
    );
  }
}
