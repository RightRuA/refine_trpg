import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/navigation_service.dart';

class CreateRoomScreen extends StatefulWidget {
  static const String routeName = '/create-room';

  const CreateRoomScreen({super.key});

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  // 폼 유효성 검사를 위한 키
  final _formKey = GlobalKey<FormState>();
  String _roomName = '';
  int _maxPlayers = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('방 만들기'),
        backgroundColor: Color(0xFF8C7853),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 이전 화면으로 돌아가기
            NavigationService.goBack();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: '방 제목',
                  border: OutlineInputBorder(),
                ),
                // 입력된 방 제목 저장
                onSaved: (value) => _roomName = value?.trim() ?? '',
                // 방 제목 필수 입력 검증
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '방 제목을 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('최대 플레이어 수: $_maxPlayers'),
              // 플레이어 수 조절 슬라이더 (2~8명)
              Slider(
                value: _maxPlayers.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                label: _maxPlayers.toString(),
                onChanged: (value) {
                  setState(() {
                    _maxPlayers = value.toInt();
                  });
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 폼 유효성 검사 후 방 생성
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('방이 생성되었습니다: $_roomName')),
                      );
                      NavigationService.goBack();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Color(0xFF2A3439),
                  ),
                  child: Text('방 만들기', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
