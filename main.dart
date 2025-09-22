import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(SmartPortagemApp());
}

class SmartPortagemApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portagem Inteligente',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(), // abre splash primeiro
    );
  }
}
