import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // 건강 상태 데이터 (추후에는 이것도 Firebase나 Provider에서 가져와야 함)
  double healthScore = 40; // 0~100 (낮으면 아픔)
  double diabetesRisk = 0.8; // 당뇨 위험도 (0.0 ~ 1.0)
  double hbpRisk = 0.3; // 고혈압 위험도

  @override
  Widget build(BuildContext context) {
    // ★ [핵심] Provider에 있는 내 정보 가져오기 (이름, 성별, 포인트 등)
    // context.watch를 쓰면 데이터가 바뀔 때마다 화면이 새로고침 됩니다.
    final user = context.watch<UserProvider>();

    return Scaffold(
      // 상단 앱바 (포인트 표시용)
      appBar: AppBar(
        title: const Text("내 캐릭터"),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cookie, color: Colors.brown, size: 20),
                  const SizedBox(width: 5),
                  // ★ [수정] 내 진짜 포인트 보여주기
                  Text(
                    "${user.point} P", 
                    style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. 캐릭터 영역
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ★ [수정] 성별과 건강 상태에 따라 다른 이미지 보여주는 함수 호출
                    _buildCharacterImage(user.gender, healthScore),
                    
                    const SizedBox(height: 20),
                    
                    // ★ [추가] 이름과 페르소나(유형) 표시
                    Text(
                      user.name.isEmpty ? "이름없음" : user.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "(${user.persona})", 
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 말풍선 (상태 메시지)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        healthScore < 50 ? "배고파요... 밥 좀 주세요..." : "오늘 컨디션 최고!",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 건강 위험도 UI (당뇨, 고혈압)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("⚠️ 건강 위험 경보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildRiskBar("당뇨 위험", diabetesRisk, Colors.orange),
                    const SizedBox(height: 15),
                    _buildRiskBar("고혈압 위험", hbpRisk, Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ★ [추가] 캐릭터 이미지 분기 처리 함수
  Widget _buildCharacterImage(String gender, double health) {
    IconData charIcon;
    Color color;

    if (health < 50) {
      // 건강 점수가 낮으면 아픈 아이콘 (성별 무관)
      charIcon = Icons.sick;
      color = Colors.green; // 아픈 색깔
    } else {
      // 건강하면 성별에 따라 다르게
      if (gender == 'M') {
        charIcon = Icons.face; // 남자
        color = Colors.blue;
      } else {
        charIcon = Icons.face_3; // 여자
        color = Colors.pink;
      }
    }

    return Icon(charIcon, size: 150, color: color);
  }

  // 위험도 게이지 바 만드는 함수 (기존 유지)
  Widget _buildRiskBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value, // 0.0 ~ 1.0
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}