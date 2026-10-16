import 'package:finance_management_system/frontend/flutter/bootstrap.dart';
import 'package:finance_management_system/frontend/flutter/screens/home_screen.dart';
import 'package:finance_management_system/frontend/flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  await bootstrap();
  runApp(const FMS());
}

class FMS extends StatelessWidget {
  const FMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance',
      navigatorKey: navigatorKey,
      theme: AppTheme.light(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
