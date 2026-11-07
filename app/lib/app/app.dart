import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prism_ui/prism_ui.dart';

import '../features/shell/app_shell.dart';
import 'l10n.dart';
import 'theme.dart';

class SonoraApp extends StatelessWidget {
  const SonoraApp({super.key});

  @override
  Widget build(BuildContext context) => PrismApp(
    title: 'Sonora',
    theme: sonoraTheme(Brightness.light),
    darkTheme: sonoraTheme(Brightness.dark),
    themeMode: ThemeMode.dark,
    locale: const Locale('zh'),
    supportedLocales: const [Locale('zh'), Locale('en')],
    localizationsDelegates: const [
      GlobalWidgetsLocalizations.delegate,
      SonoraLocalizations.delegate,
    ],
    debugShowCheckedModeBanner: false,
    home: const AppShell(),
  );
}
