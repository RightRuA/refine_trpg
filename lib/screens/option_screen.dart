import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/navigation_service.dart';

class OptionsScreen extends StatefulWidget {
  static const String routeName = '/options';

  const OptionsScreen({super.key});

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedTheme = '기본';

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
                title: Text('계정 정보'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // 계정 정보 화면으로 이동
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('도움말'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // 도움말 화면으로 이동
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('앱 정보'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // 앱 정보 화면으로 이동
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
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('다크'),
                value: '다크',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('라이트'),
                value: '라이트',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
