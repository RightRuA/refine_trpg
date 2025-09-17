import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // API 서버 주소 설정
  static const _baseUrl = 'http://localhost:11122';
  static const _signUpUrl = '$_baseUrl/users'; // 회원가입 엔드포인트
  static const _loginUrl = '$_baseUrl/auth/login'; // 로그인 엔드포인트

  /// 회원가입 API 호출 (POST /users)
  /// - 성공 시 true, 실패 시 false 반환
  static Future<bool> signup({
    required String name,
    required String nickname,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_signUpUrl);
    final body = {
      'name': name,
      'nickname': nickname,
      'email': email,
      'password': password,
    };

    print('[AuthService] signup 호출 URL: $uri');
    print('[AuthService] 보낼 Body: $body');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'}, // JSON 형식으로 데이터 전송
      body: jsonEncode(body),
    );

    print('[AuthService] Response Code: ${response.statusCode}');
    print('[AuthService] Response Body: ${response.body}');

    // 201 Created 또는 200 OK면 성공으로 처리
    return response.statusCode == 201 || response.statusCode == 200;
  }

  /// 로그인 API 호출
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_loginUrl);
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    // HTTP 상태코드 2xx면 성공
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final token = body['access_token']; // 백엔드에서 발급하는 JWT 토큰

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token); // 로컬에 토큰 저장

      print('[AuthService] 토큰 저장 완료: $token');
      return true;
    } else {
      print('[AuthService] 로그인 실패: ${res.statusCode} ${res.body}');
    }

    return false;
  }
}
