import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/security/lock_manager.dart';

/// Application entry point.
///
/// Initializes:
/// 1. Flutter bindings
/// 2. System UI (status bar style)
/// 3. Screen orientation (portrait only)
/// 4. Lock manager (auto-lock)
/// 5. Riverpod scope
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation (executive apps don't rotate)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFE8EDF2),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize lock manager
  LockManager.instance.initialize();

  runApp(
    const ProviderScope(
      child: MudiriApp(),
    ),
  );
}
