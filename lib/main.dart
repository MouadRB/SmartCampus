import 'package:flutter/material.dart';

import 'package:smart_campus/core/injection/injection_container.dart' as di;

Future<void> main() async {
  // Ensures Flutter engine bindings are ready before any plugin or
  // async platform call is made — required before di.init().
  WidgetsFlutterBinding.ensureInitialized();

  // Wire the entire dependency graph before the widget tree is built.
  // Any sl<T>() call made during widget construction will resolve correctly.
  await di.init();

  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SmartCampus Companion',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('SmartCampus Companion'),
        ),
      ),
    );
  }
}
