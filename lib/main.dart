import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import 'app/app_shell.dart';
import 'core/DI/injection_container.dart' as di;
import 'core/config/environment_config.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
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
    return BlocProvider(
      // App-wide, not per-screen: see the comment on CartCubit's
      // registration in injection_container.dart. Provided here, above
      // AppShell, so both the bottom-nav badge and any pushed route
      // (e.g. ProductDetailPage's "Agregar al carrito") share one cart.
      create: (_) => di.sl<CartCubit>()..load(),
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: InterCommerceTheme.light(),
        darkTheme: InterCommerceTheme.dark(),
        home: const AppShell(),
      ),
    );
  }
}
