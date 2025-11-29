import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'diet_tab.dart'; 
import 'shop_tab.dart'; 
import 'friend_tab.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 번호 (0: 홈)

  // 탭별 화면 리스트
  final List<Widget> _tabs = [
    const HomeTab(),   // 1. 홈 (캐릭터)
    const DietTab(),   // 2. 식단
    const ShopTab(),   // 3. 상점
    const FriendTab(), // 4. 친구
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 선택된 화면 보여주기
      body: _tabs[_selectedIndex], 
      
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상일 때 필수
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // 선택된 아이콘 색
        unselectedItemColor: Colors.grey, // 안 선택된 아이콘 색
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.rice_bowl), label: '식단'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: '상점'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구'),
        ],
      ),
    );
  }
}