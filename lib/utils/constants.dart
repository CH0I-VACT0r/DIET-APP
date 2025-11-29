import 'package:flutter/material.dart';

/// 앱 전역 상수
class AppConstants {
  // 색상
  static const Color primaryColor = Color(0xFF4ECDC4);
  static const Color secondaryColor = Color(0xFF95E1D3);
  static const Color accentColor = Color(0xFFF38181);
  
  // 문자열
  static const String appName = '건강한 식습관';
  
  // 식사 유형
  static const List<String> mealTypes = [
    '아침',
    '점심',
    '저녁',
    '간식',
  ];
  
  // 페르소나 유형
  static const List<String> personaTypes = [
    '대학생',
    '대학원생',
    '직장인',
    '취준생',
  ];
}

