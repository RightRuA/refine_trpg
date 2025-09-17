// screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _nickname = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;

  Future<void> _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // 비밀번호 일치 여부 재확인 (폼 저장 후)
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signup(
        name: _name,
        nickname: _nickname,
        email: _email,
        password: _password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '회원가입 성공! 로그인해주세요.')),
        );
        NavigationService.goBack();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'] ?? '회원가입 실패')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 중 오류 발생: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입'), backgroundColor: Color(0xFF8C7853)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 이름 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _name = v?.trim() ?? '',
                validator: (v) {
                  if (v == null || v.isEmpty) return '이름을 입력하세요';
                  if (v.trim().length < 2) return '이름은 2자 이상이어야 합니다';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 닉네임 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _nickname = v?.trim() ?? '',
                validator: (v) {
                  if (v == null || v.isEmpty) return '닉네임을 입력하세요';
                  if (v.trim().length < 2) return '닉네임은 2자 이상이어야 합니다';
                  if (v.trim().length > 20) return '닉네임은 20자 이하여야 합니다';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 이메일 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _email = v?.trim() ?? '',
                validator: (v) {
                  if (v == null || v.isEmpty) return '이메일을 입력하세요';
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(v)) return '유효한 이메일을 입력하세요';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 비밀번호 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSaved: (v) => _password = v?.trim() ?? '', // ✅ trim 추가
                validator: (v) {
                  if (v == null || v.isEmpty) return '비밀번호를 입력하세요';
                  if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다';
                  final passwordRegex = RegExp(
                    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
                  );
                  if (!passwordRegex.hasMatch(v)) {
                    return '비밀번호는 문자, 숫자, 특수문자를 모두 포함해야 합니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // 비밀번호 확인 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSaved: (v) => _confirmPassword = v?.trim() ?? '', // ✅ trim 추가
                validator: (v) {
                  if (v == null || v.isEmpty) return '비밀번호를 다시 입력하세요';
                  // 폼 저장 후 실제 값과 비교하기 위해 여기서는 단순 null 체크만
                  return null;
                },
              ),
              SizedBox(height: 24),

              // 회원가입 버튼
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSignupPressed,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Color(0xFFD4AF37),
                          foregroundColor: Color(0xFF2A3439),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
