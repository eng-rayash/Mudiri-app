import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Mudiri Application Root Widget.
///
/// Configures:
/// - Material 3 theme (Neumorphism)
/// - Arabic locale (RTL-first)
/// - GoRouter navigation
/// - Riverpod state management
/// - Dynamic theme mode via ThemeNotifier
class MudiriApp extends ConsumerWidget {
  const MudiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      // App Identity
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme — dynamic mode
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Locale — Arabic first
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: AppRouter.router,
    );
  }
}
