import 'package:flutter/material.dart';

import 'pages/setup_page.dart';

class DixitScorekeeperApp extends StatelessWidget {
  const DixitScorekeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dixit Scorekeeper',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const SetupPage(),
    );
  }
}
