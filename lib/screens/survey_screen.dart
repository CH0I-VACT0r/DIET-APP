import 'package:flutter/material.dart';

/// 식습관 자가진단 화면
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식습관 자가진단'),
      ),
      body: const Center(
        child: Text('식습관 자가진단 화면'),
      ),
    );
  }
}

