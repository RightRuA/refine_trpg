import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/browser_client.dart' as http_browser;
import '../models/room.dart';

class RoomServiceException implements Exception {
  final String message;
  final int? statusCode;

  RoomServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'RoomServiceException: $message (code: $statusCode)';
}

class RoomService {
  // API 서버의 기본 URL
  static const _baseUrl = 'http://localhost:11122';

  // HTTP 클라이언트 싱글톤 인스턴스
  static http.Client? _sharedClient;

  // 플랫폼에 따라 적절한 HTTP 클라이언트 반환 (웹/모바일 구분)
  static http.Client _client() {
    if (_sharedClient != null) return _sharedClient!;

    if (kIsWeb) {
      // 웹 환경에서는 쿠키 인증을 위해 withCredentials 설정
      final c = http_browser.BrowserClient()..withCredentials = true;
      _sharedClient = c;
      return c;
    } else {
      // 모바일 환경에서는 기본 HTTP 클라이언트 사용
      _sharedClient = http.Client();
      return _sharedClient!;
    }
  }

  // HTTP 클라이언트 리소스 해제
  static void closeClient() {
    _sharedClient?.close();
    _sharedClient = null;
  }

  // HTTP 요청 헤더 생성 (인증 토큰 포함)
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}
    }
    return headers;
  }

  // API 에러 응답에서 메시지 추출
  static String _parseErrorMessage(String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          return message;
        }
      }
    } catch (e) {
      return responseBody;
    }
    return '요청을 처리할 수 없습니다.';
  }

  // 새로운 방 생성
  static Future<Room> createRoom(Room room) async {
    final uri = Uri.parse('$_baseUrl/rooms');
    final client = _client();
    try {
      final res = await client.post(
        uri,
        headers: await _headers(withAuth: true),
        body: jsonEncode(room.toCreateJson()),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방 ID로 방 정보 조회
  static Future<Room> getRoomById(String roomId) async {
    final uri = Uri.parse('$_baseUrl/rooms/${Uri.encodeComponent(roomId)}');
    final client = _client();
    try {
      final res = await client.get(
        uri,
        headers: await _headers(withAuth: true),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방에 비밀번호로 입장
  static Future<Room> joinRoom(
    String roomId, {
    required String password,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/rooms/${Uri.encodeComponent(roomId)}/join',
    );
    final client = _client();
    try {
      final res = await client.post(
        uri,
        headers: await _headers(withAuth: true),
        body: jsonEncode({'password': password}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방에서 퇴장
  static Future<void> leaveRoom(String roomId) async {
    final uri = Uri.parse(
      '$_baseUrl/rooms/${Uri.encodeComponent(roomId)}/leave',
    );
    final client = _client();
    try {
      final res = await client.post(
        uri,
        headers: await _headers(withAuth: true),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return;
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방 삭제
  static Future<void> deleteRoom(String roomId) async {
    final uri = Uri.parse('$_baseUrl/rooms/${Uri.encodeComponent(roomId)}');
    final client = _client();
    try {
      final res = await client.delete(
        uri,
        headers: await _headers(withAuth: true),
      );

      // 204 No Content는 성공적으로 삭제됨을 의미
      if (res.statusCode == 204) {
        return;
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }
}
