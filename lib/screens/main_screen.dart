// screens/main_screen.dart
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthService.isTokenValid();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRPG 메인 화면'),
        centerTitle: true,
        backgroundColor: Color(0xFF8C7853),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await AuthService.clearToken();
                if (mounted) {
                  setState(() {
                    _isLoggedIn = false;
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('로그아웃되었습니다.')));
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TRPG에 오신 것을 환영합니다!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    if (!_isLoggedIn) ...[
                      // 로그인하지 않은 경우
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            NavigationService.navigateTo(Routes.login);
                          },
                          style: _buttonStyle,
                          child: Text('로그인', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            NavigationService.navigateTo(Routes.signup);
                          },
                          style: _buttonStyle,
                          child: Text('회원가입', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ] else ...[
                      // 로그인한 경우
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            NavigationService.navigateTo(Routes.createRoom);
                          },
                          icon: Icon(Icons.add),
                          label: Text('방 만들기', style: TextStyle(fontSize: 18)),
                          style: _buttonStyle,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            NavigationService.navigateTo(Routes.findRoom);
                          },
                          icon: Icon(Icons.search),
                          label: Text('방 찾기', style: TextStyle(fontSize: 18)),
                          style: _buttonStyle,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            NavigationService.navigateTo(Routes.options);
                          },
                          icon: Icon(Icons.settings),
                          label: Text('설정', style: TextStyle(fontSize: 18)),
                          style: _buttonStyle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // 공통 버튼 스타일
  final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 14),
    backgroundColor: Color(0xFFD4AF37),
    foregroundColor: Color(0xFF2A3439),
    side: BorderSide(color: Colors.blueAccent, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
