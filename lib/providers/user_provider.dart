// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String name = "";
  String gender = "M";
  String persona = "";
  int point = 0;
  
  // 데이터가 있는지 확인하는 플래그
  bool isInitialized = false; 

  // [1] 정보 저장 (앱 껐다 켜도 유지되도록)
  Future<void> saveUserInfo(String inputName, String inputGender, String inputPersona) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 변수 업데이트
    name = inputName;
    gender = inputGender;
    persona = inputPersona;
    isInitialized = true;

    // 디스크에 저장
    await prefs.setString('user_name', inputName);
    await prefs.setString('user_gender', inputGender);
    await prefs.setString('user_persona', inputPersona);
    await prefs.setInt('user_point', point);
    await prefs.setBool('is_setup_complete', true); // "가입 완료함" 도장 쾅!
    
    notifyListeners();
  }

  // [2] 정보 불러오기 (앱 켤 때 실행)
  Future<bool> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 저장된 데이터가 없으면 false 반환
    if (!prefs.containsKey('is_setup_complete')) {
      return false; 
    }

    // 데이터 불러와서 변수에 넣기
    name = prefs.getString('user_name') ?? "";
    gender = prefs.getString('user_gender') ?? "M";
    persona = prefs.getString('user_persona') ?? "";
    point = prefs.getInt('user_point') ?? 0;
    isInitialized = true;

    notifyListeners();
    return true; // 불러오기 성공
  }

  // [3] 로그아웃 (데이터 초기화 - 테스트용)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 저장소 싹 비우기
    name = "";
    persona = "";
    isInitialized = false;
    notifyListeners();
  }
}