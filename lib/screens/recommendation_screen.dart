import 'package:flutter/material.dart';

/// 맞춤 식단 추천 화면
class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맞춤 식단 추천'),
      ),
      body: const Center(
        child: Text('맞춤 식단 추천 화면'),
      ),
    );
  }
}

