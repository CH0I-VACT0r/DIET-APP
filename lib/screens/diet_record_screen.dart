import 'package:flutter/material.dart';

/// 식단 기록 및 분석 화면
class DietRecordScreen extends StatefulWidget {
  const DietRecordScreen({super.key});

  @override
  State<DietRecordScreen> createState() => _DietRecordScreenState();
}

class _DietRecordScreenState extends State<DietRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 기록'),
      ),
      body: const Center(
        child: Text('식단 기록 화면'),
      ),
    );
  }
}

