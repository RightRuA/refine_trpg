// screens/room_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/navigation_service.dart';
// 假设这些文件存在于你的项目中，并且路径正确
// 如果不存在，你需要从旧项目复制它们或创建占位符
import '../models/room.dart';
// import '../services/chat_service.dart'; // 暂时注释掉，如果需要再取消注释
// import '../models/chat.dart'; // 暂时注释掉，如果需要再取消注释
// import '../features/character_sheet/character_sheet_router.dart'; // 暂时注释掉
// import '../widgets/chat_bubble_widget.dart'; // 暂时注释掉
// import '../features/character_sheet/systems.dart'; // 暂时注释掉
// import '../systems/core/dice.dart'; // 暂时注释掉
// import '../systems/core/rules_engine.dart'; // 暂时注释掉
// import '../systems/dnd5e/dnd5e_rules.dart'; // 暂时注释掉
// import '../systems/coc7e/coc7e_rules.dart'; // 暂时注释掉

class RoomScreen extends StatefulWidget {
  static const String routeName = '/room';

  // 修改: 接收 Room 对象作为必需参数
  final Room room;
  const RoomScreen({super.key, required this.room});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  // 使用 widget.room 作为当前房间
  late Room _room;

  // 暂时注释掉未实现的依赖项
  // late final ChatService _chatService;
  final String _playerName = '플레이어'; // 简化处理

  // 移除 GlobalKey<ScaffoldState> _scaffoldKey
  final TextEditingController _chatController = TextEditingController();
  // 暂时注释掉未实现的依赖项
  // final List<ChatMessage> _messages = [];
  final ScrollController _msgScroll = ScrollController();

  // 简化状态
  int? selectedCharacterIndex;
  bool isRightDrawerOpen = false;
  bool isLeftDrawerOpen = false;
  bool isDicePanelOpen = false;

  // 简化处理
  final List<int> diceFaces = [2, 4, 6, 8, 10, 20, 100];
  Map<int, int> diceCounts = {
    for (var f in [2, 4, 6, 8, 10, 20, 100]) f: 0,
    -1: 0,
  };

  // 简化处理
  late final String systemId;
  // late final TrpgRules rules; // 暂时注释掉

  // 简化处理
  late Map<String, TextEditingController> statControllers;
  late Map<String, TextEditingController> generalControllers;

  @override
  void initState() {
    super.initState();
    // 使用传入的 room 对象
    _room = widget.room;

    // 简化初始化
    systemId = 'coc7e'; // 默认系统
    // rules = systemId == 'dnd5e' ? Dnd5eRules() : Coc7eRules(); // 暂时注释掉

    // 简化控制器初始化 (使用示例数据)
    statControllers = {
      'strength': TextEditingController(text: '10'),
      'dexterity': TextEditingController(text: '10'),
    };
    generalControllers = {
      'name': TextEditingController(text: 'Default Character'),
      'HP': TextEditingController(text: '10'),
    };
  }

  // 简化方法
  Map<String, dynamic> _collectCurrentData() {
    return {
      'stats': {
        for (final e in statControllers.entries)
          e.key: int.tryParse(e.value.text) ?? e.value.text,
      },
      'general': {
        for (final e in generalControllers.entries)
          e.key: int.tryParse(e.value.text) ?? e.value.text,
      },
    };
  }

  // 简化方法
  Map<String, dynamic> _deriveCurrent() {
    // 返回一些示例派生值
    return {'hp': 10, 'mp': 5};
  }

  // 简化方法
  void _handleSendClick() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    // 简化处理
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('채팅 기능은 현재 비활성화되어 있습니다.')));
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 移除 key: _scaffoldKey,
      appBar: AppBar(
        title: Text('방: ${_room.name}'), // 使用房间名
        backgroundColor: Color(0xFF8C7853),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            NavigationService.goBack(); // 使用 NavigationService 返回
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
                      '방 ID: ${_room.id ?? 'Unknown'}', // 显示房间ID
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 하단 채팅 입력 영역 (VTT 위에 얹히지만 포인터 방해 없음)
          Column(
            children: [
              // 가운데 빈 레이어가 포인터를 막지 않도록 IgnorePointer 처리
              Expanded(
                child: IgnorePointer(
                  ignoring: true,
                  child: const SizedBox.expand(),
                ),
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
                        onSubmitted: (_) => _handleSendClick(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      // onTap: _openChatPanel, // 暂时注释掉
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
                      onTap: _handleSendClick,
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
          // 주사위 패널 (简化显示)
          if (isDicePanelOpen)
            Positioned(
              right: 16,
              bottom: 80, // 调整位置避免与输入框重叠
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
                        ElevatedButton(
                          onPressed: () {
                            // 简化处理: 显示一个随机数
                            final randomResult = Random().nextInt(20) + 1;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('d20 결과: $randomResult')),
                            );
                            setState(() {
                              isDicePanelOpen = false;
                            });
                          },
                          child: const Text('d20 굴리기'),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _msgScroll.dispose();
    // Dispose controllers
    for (var controller in statControllers.values) {
      controller.dispose();
    }
    for (var controller in generalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
