// services/room_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/browser_client.dart' as http_browser;
import 'dart:io'; // 네트워크 예외 처리용
import 'dart:async'; // 타임아웃 처리용
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
        // 다양한 에러 형식 처리
        if (decoded.containsKey('errors') && decoded['errors'] is List) {
          final errors = decoded['errors'] as List;
          if (errors.isNotEmpty) {
            final firstError = errors[0];
            if (firstError is Map<String, dynamic> &&
                firstError.containsKey('message')) {
              return firstError['message'] as String;
            }
          }
        }

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

  // 타임아웃이 있는 HTTP 요청
  static Future<http.Response> _requestWithTimeout(
    Future<http.Response> request, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await request.timeout(timeout);
    } on TimeoutException {
      throw RoomServiceException('서버 응답 시간이 초과되었습니다.', statusCode: 408);
    }
  }

  // 새로운 방 생성
  static Future<Room> createRoom(Room room) async {
    final uri = Uri.parse('$_baseUrl/rooms');
    final client = _client();
    try {
      final res = await _requestWithTimeout(
        client.post(
          uri,
          headers: await _headers(withAuth: true),
          body: jsonEncode(room.toCreateJson()),
        ),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow; // 이미 RoomServiceException인 경우 그대로 전달
    } catch (e) {
      throw RoomServiceException('방 생성 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방 ID로 방 정보 조회
  static Future<Room> getRoomById(String roomId) async {
    final uri = Uri.parse('$_baseUrl/rooms/${Uri.encodeComponent(roomId)}');
    final client = _client();
    try {
      final res = await _requestWithTimeout(
        client.get(uri, headers: await _headers(withAuth: true)),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 정보 조회 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방 목록 조회 (페이지네이션 지원)
  static Future<List<Room>> getRooms({int page = 1, int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/rooms?page=$page&limit=$limit');
    final client = _client();
    try {
      final res = await _requestWithTimeout(
        client.get(uri, headers: await _headers(withAuth: true)),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> body = jsonDecode(res.body);
        return body
            .map((e) => Room.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 목록 조회 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close();
    }
  }

  // 방 검색
  static Future<List<Room>> searchRooms(String keyword) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final uri = Uri.parse('$_baseUrl/rooms/search?q=$encodedKeyword');
    final client = _client();
    try {
      final res = await _requestWithTimeout(
        client.get(uri, headers: await _headers(withAuth: true)),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> body = jsonDecode(res.body);
        return body
            .map((e) => Room.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 검색 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close();
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
      final res = await _requestWithTimeout(
        client.post(
          uri,
          headers: await _headers(withAuth: true),
          body: jsonEncode({'password': password}),
        ),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 입장 중 오류가 발생했습니다: ${e.toString()}');
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
      final res = await _requestWithTimeout(
        client.post(uri, headers: await _headers(withAuth: true)),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return;
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 퇴장 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방 삭제
  static Future<void> deleteRoom(String roomId) async {
    final uri = Uri.parse('$_baseUrl/rooms/${Uri.encodeComponent(roomId)}');
    final client = _client();
    try {
      final res = await _requestWithTimeout(
        client.delete(uri, headers: await _headers(withAuth: true)),
      );

      // 204 No Content는 성공적으로 삭제됨을 의미
      if (res.statusCode == 204) {
        return;
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 삭제 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close(); 싱글톤이므로 닫지 않음
    }
  }

  // 방 정보 업데이트
  static Future<Room> updateRoom(
    String roomId,
    Map<String, dynamic> updates,
  ) async {
    final uri = Uri.parse('$_baseUrl/rooms/${Uri.encodeComponent(roomId)}');
    final client = _client();
    try {
      final res = await _requestWithTimeout(
        client.patch(
          uri,
          headers: await _headers(withAuth: true),
          body: jsonEncode(updates),
        ),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return Room.fromJson(body);
      }

      final errorMessage = _parseErrorMessage(res.body);
      throw RoomServiceException(errorMessage, statusCode: res.statusCode);
    } on SocketException {
      throw RoomServiceException('네트워크 연결을 확인해주세요.');
    } on RoomServiceException {
      rethrow;
    } catch (e) {
      throw RoomServiceException('방 정보 업데이트 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      // client.close();
    }
  }

  // 앱 종료 시 리소스 정리
  static void dispose() {
    closeClient();
  }
}
