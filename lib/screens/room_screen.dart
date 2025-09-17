// screens/room_screen.dart
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../models/chat.dart';
import '../widgets/chat_bubble_widget.dart';
import '../services/navigation_service.dart';
import 'dart:io';
import 'dart:async';

class RoomScreen extends StatefulWidget {
  final Room room;
  const RoomScreen({super.key, required this.room});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late Room _room;
  final String _baseUrl = 'http://localhost:11122';
  final String _playerName = '플레이어';

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _msgScroll = ScrollController();

  // 상태 변수들
  bool isDicePanelOpen = false;
  bool _isLoading = false;
  bool _isChatPanelOpen = false;

  // 주사위 패널
  final List<int> diceFaces = [2, 4, 6, 8, 10, 20, 100];
  Map<int, int> diceCounts = {
    for (var f in [2, 4, 6, 8, 10, 20, 100]) f: 0,
    -1: 0,
  };

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _loadChatMessages();
  }

  // ===== 채팅 서비스 로직 통합 시작 =====
  Future<List<ChatMessage>> _getChatMessages(String roomId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/rooms/$roomId/chats/logs'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  Future<void> _sendChatMessageToServer(
    String roomId,
    String sender,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/rooms/$roomId/chats'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'sender': sender, 'message': message}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send chat message');
    }
  }
  // ===== 채팅 서비스 로직 통합 끝 =====

  // 채팅 메시지 불러오기
  Future<void> _loadChatMessages() async {
    if (_room.id == null) return;

    setState(() => _isLoading = true);
    try {
      final messages = await _getChatMessages(_room.id!);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } on SocketException {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('네트워크 연결을 확인해주세요.');
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('서버 응답 시간이 초과되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('채팅 메시지를 불러오는데 실패했습니다.');
      }
    }
  }

  // 채팅 메시지 전송
  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _room.id == null) return;

    try {
      await _sendChatMessageToServer(_room.id!, _playerName, text);

      if (mounted) {
        setState(() {
          _chatController.clear();
        });

        final newMessage = ChatMessage(
          sender: _playerName,
          content: text,
          timestamp: DateTime.now(),
        );

        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
        _showSuccessMessage('메시지가 전송되었습니다.');
      }
    } on SocketException {
      if (mounted) {
        _showErrorMessage('네트워크 연결을 확인해주세요.');
      }
    } on TimeoutException {
      if (mounted) {
        _showErrorMessage('서버 응답 시간이 초과되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('메시지 전송에 실패했습니다.');
      }
    }
  }

  // 주사위 결과 전송
  Future<void> _sendDiceResult(String diceResult) async {
    if (_room.id == null) return;

    try {
      await _sendChatMessageToServer(_room.id!, _playerName, diceResult);

      final newMessage = ChatMessage(
        sender: _playerName,
        content: diceResult,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
        _showSuccessMessage('주사위 결과가 전송되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('주사위 결과 전송에 실패했습니다.');
      }
    }
  }

  // 채팅 패널 열기
  void _openChatPanel() {
    setState(() {
      _isChatPanelOpen = true;
    });
  }

  // 채팅 패널 닫기
  void _closeChatPanel() {
    setState(() {
      _isChatPanelOpen = false;
    });
  }

  // 스크롤을 맨 아래로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_msgScroll.hasClients) {
        _msgScroll.animateTo(
          _msgScroll.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 에러 메시지 표시
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // 성공 메시지 표시
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('방: ${_room.name}'),
        backgroundColor: Color(0xFF8C7853),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            NavigationService.goBack();
          },
        ),
      ),
      body: Stack(
        children: [
          // === VTT 캔버스: 맨 아래 레이어 (배경/마커) ===
          Positioned.fill(
            child: Container(
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'VTT 기능은 현재 비활성화되어 있습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '방 ID: ${_room.id ?? 'Unknown'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 채팅 패널
          if (_isChatPanelOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // 헤더
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: _closeChatPanel,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '채팅',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 채팅 메시지 목록
                    Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              controller: _msgScroll,
                              itemCount: _messages.length,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemBuilder: (context, i) {
                                final message = _messages[i];
                                return ChatBubbleWidget(
                                  playerName: message.sender,
                                  message: message.content,
                                );
                              },
                            ),
                    ),
                    // 입력 영역
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: '메시지를 입력하세요...',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _sendChatMessage(),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.send, color: Colors.blue),
                            onPressed: _sendChatMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 주사위 패널
          if (isDicePanelOpen)
            Positioned(
              right: 16,
              bottom: 80,
              child: SizedBox(
                width: 300,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '주사위 패널',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('방 ID: ${_room.id}'),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: diceFaces.map((face) {
                            return GestureDetector(
                              onTap: () => setState(
                                () => diceCounts[face] = diceCounts[face]! + 1,
                              ),
                              onSecondaryTap: () => setState(
                                () => diceCounts[face] = max(
                                  0,
                                  diceCounts[face]! - 1,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text('d$face'),
                                    if (diceCounts[face]! > 0)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: CircleAvatar(
                                          radius: 10,
                                          child: Text(
                                            '${diceCounts[face]}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final lines = <String>[];
                            int totalAll = 0;

                            diceCounts.forEach((face, count) {
                              if (face <= 0 || count <= 0) return;
                              final results = <int>[];
                              for (int i = 0; i < count; i++) {
                                results.add(Random().nextInt(face) + 1);
                              }
                              final total = results.reduce((a, b) => a + b);
                              totalAll += total;
                              lines.add(
                                '${count}d$face: ${results.join(', ')} = $total',
                              );
                            });

                            final msg = lines.isEmpty
                                ? '주사위 선택이 없습니다.'
                                : '[주사위]\n${lines.join('\n')}\n총합: $totalAll';

                            // 주사위 결과를 채팅으로 전송
                            await _sendDiceResult(msg);

                            if (mounted) {
                              setState(() {
                                isDicePanelOpen = false;
                                diceCounts = {
                                  for (var f in diceFaces) f: 0,
                                  -1: 0,
                                };
                              });
                            }
                          },
                          child: const Text('굴리기'),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => isDicePanelOpen = false),
                          child: const Text('닫기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 하단 채팅 입력 영역
          Column(
            children: [
              Expanded(
                child: IgnorePointer(ignoring: true, child: SizedBox.expand()),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                color: const Color(0xFFF0F0F0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: '채팅을 입력하기...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendChatMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openChatPanel,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => isDicePanelOpen = true),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.casino,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _sendChatMessage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _msgScroll.dispose();
    super.dispose();
  }
}
