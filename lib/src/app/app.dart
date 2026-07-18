import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class LedgerFlowApp extends StatelessWidget {
  const LedgerFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
