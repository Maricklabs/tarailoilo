import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../widgets/connectivity_banner.dart';
import 'router.dart';
import 'theme.dart';

/// Root widget of the app.
///
/// It reads the [GoRouter] from [routerProvider] and wraps every screen with
/// the global [ConnectivityBanner] so the online/offline strip appears on all
/// pages (requirement from section 4 "Global elements").
class TaraIloApp extends ConsumerWidget {
  const TaraIloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) =>
          ConnectivityBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
