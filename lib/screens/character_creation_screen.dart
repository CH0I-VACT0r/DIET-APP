// lib/screens/character_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';

class CharacterCreationScreen extends StatefulWidget {
  final String persona; // 설문조사에서 넘어온 페르소나 결과

  const CharacterCreationScreen({super.key, required this.persona});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedGender = "M"; // 기본값 남자

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("캐릭터 생성")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("반가워요! 👋\n당신의 캐릭터를 만들어볼까요?", 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            // 1. 이름 입력
            const Align(alignment: Alignment.centerLeft, child: Text("이름", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "캐릭터 닉네임을 입력하세요",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 30),

            // 2. 성별 선택
            const Align(alignment: Alignment.centerLeft, child: Text("성별", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGenderCard("남자", "M", Icons.face),
                _buildGenderCard("여자", "F", Icons.face_3),
              ],
            ),
            
            const Spacer(),

            // 3. 생성 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _createCharacter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("시작하기", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 성별 선택 카드 디자인
  Widget _buildGenderCard(String label, String genderCode, IconData icon) {
    bool isSelected = _selectedGender == genderCode;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = genderCode),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.black)),
          ],
        ),
      ),
    );
  }

  // 생성 완료 로직
  Future<void> _createCharacter() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이름을 입력해주세요!")));
      return;
    }

    // 1. 앱 내 저장소(Provider)에 저장
    context.read<UserProvider>().saveUserInfo(name, _selectedGender, widget.persona);

    // 2. Firebase DB에 저장
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'gender': _selectedGender,
      'persona': widget.persona,
      'createdAt': DateTime.now(),
      'point': 0,
    });

    // 3. 메인 화면으로 이동 (뒤로가기 못하게 pushReplacement)
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }
}