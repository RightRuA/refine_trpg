// models/room.dart
class RoomParticipantSummary {
  final int id;
  final String name;
  final String nickname;
  final String role;

  RoomParticipantSummary({
    required this.id,
    required this.name,
    required this.nickname,
    required this.role,
  });

  // JSON 데이터를 RoomParticipantSummary 객체로 변환
  factory RoomParticipantSummary.fromJson(Map<String, dynamic> json) {
    return RoomParticipantSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
    );
  }
}

class UserSummary {
  final int id;
  final String name;
  final String nickname;

  UserSummary({required this.id, required this.name, required this.nickname});

  // JSON 데이터를 UserSummary 객체로 변환
  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
    );
  }
}

// 방 정보를 표현하는 모델 클래스
class Room {
  // 방의 고유 ID (서버에서 생성)
  final String? id;

  // 방 이름
  final String name;

  // 방 비밀번호 (개인방인 경우 필요)
  final String? password;

  // 방의 최대 수용 인원
  final int maxParticipants;

  // 현재 방에 참가한 인원 수
  final int currentParticipants;

  // 방에 참가한 사용자들의 간단한 정보 목록
  final List<RoomParticipantSummary> participants;

  // 방을 생성한 사용자 정보
  final UserSummary? creator;

  Room({
    this.id,
    required this.name,
    required this.password,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.participants = const [],
    this.creator,
  });

  // 방 생성 요청 시 사용하는 JSON 형식으로 변환 (서버에 보낼 데이터)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'password': password ?? '',
      'maxParticipants': maxParticipants,
    };
  }

  // 서버에서 받은 JSON 데이터를 Room 객체로 변환
  factory Room.fromJson(Map<String, dynamic> json) {
    // 서버 응답이 { message: "...", room: { ... } } 형식일 수 있으므로 room 데이터 추출
    final data = json['room'] is Map<String, dynamic>
        ? json['room'] as Map<String, dynamic>
        : json;

    UserSummary? creator;
    if (data['creator'] != null) {
      creator = UserSummary.fromJson(data['creator'] as Map<String, dynamic>);
    }

    // 참가자 목록이 있으면 RoomParticipantSummary 객체로 변환
    final participants =
        (data['participants'] as List<dynamic>?)
            ?.map(
              (e) => RoomParticipantSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return Room(
      id: data['id']?.toString(),
      name: data['name'] as String? ?? 'no_name',
      password: data['password'] as String?,
      maxParticipants: data['maxParticipants'] as int? ?? 0,
      currentParticipants: data['currentParticipants'] as int? ?? 0,
      participants: participants,
      creator: creator,
    );
  }
}
