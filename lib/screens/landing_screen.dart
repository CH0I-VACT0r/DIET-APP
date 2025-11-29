import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'survey_screen.dart';
import 'main_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isLoading = true;
  bool _hasUser = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // 저장된 유저가 있는지 확인
  Future<void> _checkUser() async {
    // Provider의 불러오기 함수 실행
    bool exists = await context.read<UserProvider>().loadUserInfo();
    
    if (mounted) {
      setState(() {
        _hasUser = exists;
        _isLoading = false;
      });
      
      // (선택) 만약 유저가 있으면 바로 메인으로 보내고 싶다면 아래 주석 해제
      // if (exists) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.green[50], // 산뜻한 배경색
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 대신 아이콘
              const Icon(Icons.restaurant_menu, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "COOK-KEY",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const Text("자취생을 위한 스마트 식단 매니저", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 60),

              // [분기점] 유저 정보가 있으면 '이어하기', 없으면 '시작하기'
              if (_hasUser) ...[
                Text(
                  "${context.watch<UserProvider>().name}님, 환영합니다!",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const MainScreen())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("메인으로 입장하기"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    await context.read<UserProvider>().clearUser(); // 초기화
                    setState(() => _hasUser = false); // 화면 갱신
                  },
                  child: const Text("데이터 초기화하고 다시 시작하기 (테스트용)", style: TextStyle(color: Colors.grey)),
                ),
              ] else ...[
                // 유저 정보가 없을 때
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SurveyScreen())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("자가진단 시작하기"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}