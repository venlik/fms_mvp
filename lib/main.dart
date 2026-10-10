import 'package:finance_management_system/frontend/flutter/screens/business_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FMT());
}

class FMT extends StatelessWidget {
  const FMT({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BusinessScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
