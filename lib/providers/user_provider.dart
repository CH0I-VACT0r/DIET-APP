// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String name = "";       // 캐릭터 이름
  String gender = "M";    // 성별 (M:남, F:여)
  String persona = "";    // 설문조사 결과 (예: 편의점 미식가)
  int point = 0;          // 포인트

  // 정보 저장 함수
  void setUserInfo(String inputName, String inputGender, String inputPersona) {
    name = inputName;
    gender = inputGender;
    persona = inputPersona;
    notifyListeners(); // "데이터 바꼈으니까 화면 업데이트해!" 라고 알림
  }
}