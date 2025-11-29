import 'package:flutter/material.dart';

/// 캐릭터 생성 및 관리 화면
class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 캐릭터'),
      ),
      body: const Center(
        child: Text('캐릭터 화면'),
      ),
    );
  }
}

