import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import 'wardrobe_screen.dart';
import 'landing_screen.dart'; // ★ 로그아웃 후 이동할 화면 import

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // 기준치 (RDI) - 20대 평균 기준
  final double limitSodium = 2000.0;
  final double limitCarbo = 324.0;
  final double limitFat = 54.0; // 지방 권장량
  final double limitTransFat = 0.5;

  // 오늘 날짜 구하기
  String get _todayString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        // ★ [추가] 로그아웃/초기화 버튼 (왼쪽 상단)
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.grey),
          onPressed: () => _showLogoutDialog(context),
          tooltip: "초기화 및 로그아웃",
        ),
        title: const Text("내 캐릭터"),
        centerTitle: true,
        actions: [
          _buildPointBadge(user.point),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('diet_logs')
            .where('date', isEqualTo: _todayString)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("데이터 로드 실패"));
          
          final docs = snapshot.data?.docs ?? [];
          
          // 영양소 합계 계산
          Map<String, double> nutrientSum = {
            'sodium': 0, 'carbo': 0, 'trans_fat': 0, 'kcal': 0, 'fat': 0
          };
          bool hadBreakfast = false;
          bool hadLunch = false;
          bool hadDinner = false;

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            nutrientSum['sodium'] = nutrientSum['sodium']! + (double.tryParse(data['sodium']?.toString() ?? "0") ?? 0);
            nutrientSum['carbo'] = nutrientSum['carbo']! + (double.tryParse(data['carbo']?.toString() ?? "0") ?? 0);
            nutrientSum['trans_fat'] = nutrientSum['trans_fat']! + (double.tryParse(data['trans_fat']?.toString() ?? "0") ?? 0);
            nutrientSum['kcal'] = nutrientSum['kcal']! + (double.tryParse(data['kcal']?.toString() ?? "0") ?? 0);
            nutrientSum['fat'] = nutrientSum['fat']! + (double.tryParse(data['fat']?.toString() ?? "0") ?? 0);

            String type = data['mealType'] ?? '';
            if (type == 'breakfast') hadBreakfast = true;
            if (type == 'lunch') hadLunch = true;
            if (type == 'dinner') hadDinner = true;
          }

          // 상태 판정 로직
          String charState = "normal";
          String stateMessage = "오늘 컨디션 최고! 💪";
          
          int hour = DateTime.now().hour;

          if (nutrientSum['sodium']! > limitSodium) {
            charState = "sick";
            stateMessage = "으악! 너무 짜게 먹었어요... 몸이 부었어요 🤢";
          } else if (nutrientSum['trans_fat']! > limitTransFat) {
            charState = "sick";
            stateMessage = "기름진 음식 그만! 혈관이 아파요 🚑";
          } else if (nutrientSum['fat']! > limitFat) {
             charState = "obese";
             stateMessage = "기름진 음식을 너무 많이 먹었어요... 몸이 무거워요 🐷";
          } else if (
            (hour >= 10 && !hadBreakfast) || 
            (hour >= 13 && !hadLunch) ||     
            (hour >= 20 && !hadDinner)       
          ) {
            charState = "hungry";
            stateMessage = "배고파요... 밥 언제 주나요? 🤤";
          }

          double hbpRisk = (nutrientSum['sodium']! / limitSodium).clamp(0.0, 1.0);
          double diabetesRisk = (nutrientSum['carbo']! / limitCarbo).clamp(0.0, 1.0);
          double obesityRisk = (nutrientSum['fat']! / limitFat).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. 캐릭터 영역
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 340, 
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRealCharacterImage(user.gender, charState),
                                
                                const SizedBox(height: 20),
                                Text(
                                  user.name.isEmpty ? "이름없음" : user.name,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getStateColor(charState).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: _getStateColor(charState)),
                                  ),
                                  child: Text(
                                    stateMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            // 포인트샵 버튼
                            Positioned(
                              right: 0,
                              bottom: 80,
                              child: Column(
                                children: [
                                  FloatingActionButton(
                                    heroTag: "shopBtn",
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WardrobeScreen()));
                                    },
                                    backgroundColor: Colors.white,
                                    elevation: 4,
                                    child: const Icon(Icons.checkroom, color: Colors.purple, size: 28),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text("포인트샵", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. 위험도 UI
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("⚠️ 나의 건강 위험도", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildRiskBar("고혈압 위험 (나트륨)", hbpRisk, Colors.red),
                          const SizedBox(height: 15),
                          _buildRiskBar("당뇨 위험 (탄수화물)", diabetesRisk, Colors.orange),
                          const SizedBox(height: 15),
                          _buildRiskBar("비만 위험 (지방)", obesityRisk, Colors.purple),
                          
                          const SizedBox(height: 15),
                          if (hbpRisk > 0.8 || diabetesRisk > 0.8 || obesityRisk > 0.8)
                            const Text("🚨 경고: 식습관 개선이 시급합니다!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ★ [추가] 로그아웃 확인 팝업
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("초기화 하시겠습니까?"),
        content: const Text("현재 캐릭터와 포인트 정보가 기기에서 삭제되고,\n첫 화면으로 돌아갑니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 취소
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 팝업 닫기
              
              // 1. 유저 정보 초기화
              await context.read<UserProvider>().clearUser();
              
              // 2. 첫 화면(LandingScreen)으로 이동하면서 기존 화면 스택 모두 제거
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen()),
                  (route) => false, // 뒤로가기 불가능하게 만듦
                );
              }
            },
            child: const Text("초기화", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ... (아래 위젯들은 기존과 동일) ...
  Widget _buildRealCharacterImage(String gender, String state) {
    String genderPrefix = (gender == 'M') ? 'male' : 'female';
    String imagePath = 'assets/images/${genderPrefix}_$state.png';

    return Image.asset(
      imagePath,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Column(
          children: [
            Icon(Icons.broken_image, size: 80, color: Colors.grey),
            const Text("이미지 준비중", style: TextStyle(color: Colors.grey)),
          ],
        );
      },
    );
  }

  Widget _buildPointBadge(int point) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Icon(Icons.cookie, color: Colors.brown, size: 20),
          const SizedBox(width: 5),
          Text("$point P", style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Color _getStateColor(String state) {
    if (state == "sick") return Colors.red;
    if (state == "obese") return Colors.purple;
    if (state == "hungry") return Colors.grey;
    return Colors.blue;
  }

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
          value: value,
          backgroundColor: Colors.grey[200],
          color: value > 0.8 ? Colors.red : color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}