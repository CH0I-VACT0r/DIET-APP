import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'character_creation_screen.dart'; // 캐릭터 생성 화면으로 연결

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  // 질문 1: 요리할 시간이 있나요?
  bool hasTime = false;
  // 질문 2: 한 끼 예산이 5천원 넘나요?
  bool hasMoney = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("나만의 식습관 찾기")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Q1. 평소 요리할 시간이 충분한가요?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildOption("네, 여유로워요", true, hasTime, (v) => setState(() => hasTime = v)),
                const SizedBox(width: 10),
                _buildOption("아니요, 바빠요", false, hasTime, (v) => setState(() => hasTime = v)),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Q2. 한 끼 식사 예산은 어느 정도인가요?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildOption("5천원 이상", true, hasMoney, (v) => setState(() => hasMoney = v)),
                const SizedBox(width: 10),
                _buildOption("5천원 미만 (절약)", false, hasMoney, (v) => setState(() => hasMoney = v)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _analyzePersona();
                },
                child: const Text("결과 분석하기", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text, bool value, bool groupValue, Function(bool) onTap) {
    bool isSelected = (value == groupValue);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _analyzePersona() async {
    String result = "";
    if (hasTime && hasMoney) result = "건강한 미식가";
    else if (hasTime && !hasMoney) result = "알뜰한 요리사";
    else if (!hasTime && hasMoney) result = "배달음식 VIP";
    else result = "편의점 마스터";

    // 팝업으로 결과 보여주고 -> 캐릭터 생성 화면으로 이동
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("분석 완료!"),
        content: Text("당신은 [$result] 입니다!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 팝업 닫기
              
              // 캐릭터 생성 화면으로 이동 (페르소나 전달)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterCreationScreen(persona: result),
                ),
              );
            },
            child: const Text("캐릭터 만들러 가기"),
          )
        ],
      ),
    );
  }
}