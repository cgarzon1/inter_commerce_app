import 'package:flutter/material.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import 'app/app_shell.dart';
import 'core/DI/injection_container.dart' as di;
import 'core/config/environment_config.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.init();
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: InterCommerceTheme.light(),
      darkTheme: InterCommerceTheme.dark(),
      home: const AppShell(),
    );
  }
}
