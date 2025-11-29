import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/character_utils.dart';
import '../providers/character_provider.dart';
import 'party_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final String personaType;

  const ResultScreen({
    super.key,
    required this.score,
    required this.personaType,
  });

  @override
  Widget build(BuildContext context) {
    final characterImagePath = CharacterUtils.getCharacterImagePath(score);
    final hasRisk = CharacterUtils.hasHealthRisk(score);
    final riskMessage = CharacterUtils.getHealthRiskMessage(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설문 결과'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // 캐릭터 이미지
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[100],
                  child: Image.asset(
                    characterImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지가 없을 경우 플레이스홀더
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              score < 30 ? Icons.sentiment_very_dissatisfied : Icons.sentiment_very_satisfied,
                              size: 80,
                              color: score < 30 ? Colors.grey : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              score < 30 ? '좀비 상태' : '건강한 상태',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 건강 위험도 경고 박스 (점수가 낮을 때만 표시)
            if (hasRisk) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(
                    color: Colors.red[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        riskMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // 점수 표시
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '당신의 점수',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$score점',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: score < 30
                                  ? Colors.red[700]
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          score < 30
                              ? Colors.red[400]!
                              : Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 페르소나 타입 표시
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '당신의 유형',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        personaType,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getPersonaDescription(personaType),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // 다음 버튼
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // CharacterProvider에 점수 설정
                  final characterProvider = Provider.of<CharacterProvider>(context, listen: false);
                  characterProvider.updateScore(score);
                  
                  // PartyScreen으로 이동
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PartyScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text('시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPersonaDescription(String type) {
    switch (type) {
      case '건강한 식습관 유지형':
        return '규칙적인 식습관을 유지하고 계시네요! 현재 식습관을 계속 유지하시면 됩니다.';
      case '개선 가능형':
        return '약간의 개선만 하면 더 건강한 식습관을 만들 수 있습니다.';
      case '가성비 추구형':
        return '예산이 제한적인 상황에서도 건강한 식단을 추천해드리겠습니다.';
      case '개선 필요형':
        return '식습관 개선이 필요합니다. 함께 건강한 식습관을 만들어가요!';
      default:
        return '맞춤형 식단 추천을 받아보세요.';
    }
  }
}

