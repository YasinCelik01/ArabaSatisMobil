import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';  // Login ekranını dahil et

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Drawer App',
      initialRoute: '/',  // Uygulama başladığında açılacak ilk ekran
      routes: {
        '/': (context) => const HomeScreen(),  // Ana sayfa
        '/home': (context) => const HomeScreen(),  // Ana sayfa
        '/login': (context) => LoginScreen(),  // Giriş ekranı
      },
    );
  }
}
