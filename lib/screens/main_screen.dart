import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/navigation_service.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRPG 메인 화면'),
        centerTitle: true,
        backgroundColor: Color(0xFF8C7853),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TRPG에 오신 것을 환영합니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    NavigationService.navigateTo(Routes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Color(0xFF2A3439),
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Color(0xFF2A3439),
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('회원가입', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 30),
              Text(
                '게임 기능',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    NavigationService.navigateTo(Routes.createRoom);
                  },
                  icon: Icon(Icons.add),
                  label: Text('방 만들기', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Color(0xFF2A3439),
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Color(0xFF2A3439),
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Color(0xFF2A3439),
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
