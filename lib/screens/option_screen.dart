// screens/option_screen.dart
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedTheme = '기본';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 설정 불러오기
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _selectedTheme = prefs.getString('selected_theme') ?? '기본';
      });
    } catch (e) {
      print('설정 불러오기 실패: $e');
    }
  }

  // 설정 저장
  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      print('설정 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('설정 저장에 실패했습니다.')));
      }
    }
  }

  // 로그아웃 처리
  Future<void> _logout() async {
    try {
      await AuthService.clearToken();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그아웃되었습니다.')));
        // 메인 화면으로 이동 (로그인 상태가 자동으로 체크됨)
        NavigationService.pushAndRemoveUntil('/'); // Routes.main 사용
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        backgroundColor: Color(0xFF8C7853),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            NavigationService.goBack();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text('알림'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSetting('notifications_enabled', value);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('알림 설정이 저장되었습니다.')),
                      );
                    }
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('사운드'),
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                    _saveSetting('sound_enabled', value);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('사운드 설정이 저장되었습니다.')),
                      );
                    }
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('테마'),
                subtitle: Text(_selectedTheme),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  _showThemeSelectionDialog(context);
                },
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('로그아웃'),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('앱 정보'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TRPG App',
                    applicationVersion: 'v1.0.0',
                    applicationLegalese: '© 2025 My TRPG Team',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('테마 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('기본'),
                value: '기본',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTheme = value;
                    });
                    _saveSetting('selected_theme', value);
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('테마가 $_selectedTheme(으)로 변경되었습니다.'),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: Text('다크'),
                value: '다크',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTheme = value;
                    });
                    _saveSetting('selected_theme', value);
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('테마가 $_selectedTheme(으)로 변경되었습니다.'),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: Text('라이트'),
                value: '라이트',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTheme = value;
                    });
                    _saveSetting('selected_theme', value);
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('테마가 $_selectedTheme(으)로 변경되었습니다.'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }
}
