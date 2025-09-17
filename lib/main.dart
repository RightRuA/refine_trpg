import 'package:flutter/material.dart';
import './routes.dart';
import './services/navigation_service.dart';
import './screens/main_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import './screens/find_room_screen.dart';
import './screens/create_room_screen.dart';
import './screens/option_screen.dart';
// RoomScreen import 추가
import './screens/room_screen.dart';
import './models/room.dart'; // Room model import 추가

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
      onGenerateRoute: (settings) {
        // 기존 routes 매핑 처리
        if (settings.name == Routes.main) {
          return MaterialPageRoute(builder: (context) => const MainScreen());
        }
        if (settings.name == Routes.login) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
        if (settings.name == Routes.signup) {
          return MaterialPageRoute(builder: (context) => const SignupScreen());
        }
        if (settings.name == Routes.findRoom) {
          return MaterialPageRoute(
            builder: (context) => const FindRoomScreen(),
          );
        }
        if (settings.name == Routes.createRoom) {
          return MaterialPageRoute(
            builder: (context) => const CreateRoomScreen(),
          );
        }
        if (settings.name == Routes.options) {
          return MaterialPageRoute(builder: (context) => const OptionsScreen());
        }
        // RoomScreen 라우트 처리: arguments에서 Room 객체를 가져옴
        if (settings.name == Routes.room) {
          final args = settings.arguments;
          if (args is Room) {
            return MaterialPageRoute(
              builder: (context) => RoomScreen(room: args),
            );
          } else {
            // 유효한 Room 객체가 전달되지 않은 경우, 에러 페이지 표시
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Error')),
                body: Center(child: Text('Invalid room data provided.')),
              ),
            );
          }
        }
        // 정의되지 않은 라우트에 대한 처리
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Page not found: ${settings.name}')),
          ),
        );
      },
      // 기존 routes 매핑은 onGenerateRoute가 더 우선하므로 제거하거나 비워둘 수 있습니다.
      // routes: {},
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
