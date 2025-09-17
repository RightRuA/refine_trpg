// main.dart
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 라우트 빌더 맵을 클래스 레벨로 이동
  static final Map<String, WidgetBuilder> _routeBuilders = {
    Routes.main: (context) => const MainScreen(),
    Routes.login: (context) => const LoginScreen(),
    Routes.signup: (context) => const SignupScreen(),
    Routes.findRoom: (context) => const FindRoomScreen(),
    Routes.createRoom: (context) => const CreateRoomScreen(),
    Routes.options: (context) => const OptionsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'My Flutter App',
      initialRoute: Routes.main,
      onGenerateRoute: (settings) {
        // 일반 라우트 처리
        if (_routeBuilders.containsKey(settings.name)) {
          return MaterialPageRoute(builder: _routeBuilders[settings.name]!);
        }

        // RoomScreen 라우트 처리: arguments에서 Room 객체를 가져옴
        if (settings.name == Routes.room) {
          final args = settings.arguments;
          if (args != null && args is Room) {
            return MaterialPageRoute(
              builder: (context) => RoomScreen(room: args),
            );
          } else {
            // 유효한 Room 객체가 전달되지 않은 경우, 상세 에러 페이지 표시
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('데이터 오류'),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        '방 정보가 올바르지 않습니다.\n다시 시도해주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final navigator =
                              NavigationService.navigatorKey.currentState;
                          if (navigator != null && navigator.canPop()) {
                            navigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('뒤로 가기'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }

        // 정의되지 않은 라우트에 대한 사용자 친화적인 에러 처리
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('페이지를 찾을 수 없습니다'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '죄송합니다. 요청하신 페이지를 찾을 수 없습니다.\n\n요청한 경로: ${settings.name}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final navigator =
                          NavigationService.navigatorKey.currentState;
                      if (navigator != null && navigator.canPop()) {
                        navigator.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('뒤로 가기'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
