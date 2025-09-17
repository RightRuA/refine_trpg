// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // 네트워크 예외 처리용
import 'dart:async'; // 타임아웃 예외 처리용

class AuthService {
  // API 서버 주소 설정
  static const _baseUrl = 'http://localhost:11122';
  static const _signUpUrl = '$_baseUrl/users'; // 회원가입 엔드포인트
  static const _loginUrl = '$_baseUrl/auth/login'; // 로그인 엔드포인트

  /// 회원가입 API 호출 (POST /users)
  /// - 성공 시 {'success': true, 'message': '...'} 반환
  /// - 실패 시 {'success': false, 'message': '...'} 반환
  static Future<Map<String, dynamic>> signup({
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

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('[AuthService] Response Code: ${response.statusCode}');
      print('[AuthService] Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': '회원가입이 완료되었습니다.'};
      } else {
        final errorMessage = _parseErrorMessage(response.body);
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      return {'success': false, 'message': '네트워크 연결을 확인해주세요.'};
    } on TimeoutException {
      return {'success': false, 'message': '서버 응답 시간이 초과되었습니다.'};
    } catch (e) {
      print('[AuthService] 예외 발생: $e');
      return {'success': false, 'message': '회원가입 중 오류가 발생했습니다.'};
    }
  }

  /// 로그인 API 호출
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_loginUrl);

    try {
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
        return {'success': true, 'message': '로그인 성공', 'token': token};
      } else {
        print('[AuthService] 로그인 실패: ${res.statusCode} ${res.body}');
        final errorMessage = _parseErrorMessage(res.body);
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': res.statusCode,
        };
      }
    } on SocketException {
      return {'success': false, 'message': '네트워크 연결을 확인해주세요.'};
    } on TimeoutException {
      return {'success': false, 'message': '서버 응답 시간이 초과되었습니다.'};
    } catch (e) {
      print('[AuthService] 로그인 예외 발생: $e');
      return {'success': false, 'message': '로그인 중 오류가 발생했습니다.'};
    }
  }

  /// 에러 응답에서 메시지 추출
  static String _parseErrorMessage(String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        // 다양한 에러 형식 처리
        final message =
            decoded['message'] ??
            decoded['error'] ??
            decoded['detail'] ??
            '요청을 처리할 수 없습니다.';
        if (message is String) {
          return message;
        }
      }
    } catch (e) {
      return responseBody.isNotEmpty ? responseBody : '요청을 처리할 수 없습니다.';
    }
    return '요청을 처리할 수 없습니다.';
  }

  /// 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// 토큰 제거 (로그아웃)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  /// 토큰 유효성 검사
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
