// services/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  // Navigator의 상태에 접근하기 위한 전역 키
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 지정된 경로로 이동하고 필요한 경우 인자 전달
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // 이전 화면으로 돌아가기
  static void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
