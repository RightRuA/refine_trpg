import 'package:flutter/material.dart';
import './routes.dart';
import './services/navigation_service.dart';
import './screens/main_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'My Flutter App',
      initialRoute: Routes.main,
      routes: {
        Routes.main: (context) => const MainScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.signup: (context) => const SignupScreen(),
      },
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
