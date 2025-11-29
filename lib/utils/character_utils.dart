/// 캐릭터 상태 결정 유틸리티
class CharacterUtils {
  /// 점수에 따라 캐릭터 상태 결정
  /// 점수가 낮으면 'zombie', 높으면 'normal'
  static String getCharacterState(int score) {
    // 점수가 30점 미만이면 좀비 상태
    if (score < 30) {
      return 'zombie';
    }
    // 점수가 30점 이상이면 정상 상태
    return 'normal';
  }

  /// 캐릭터 이미지 경로 반환
  static String getCharacterImagePath(int score) {
    final state = getCharacterState(score);
    return state == 'zombie' ? 'assets/zombie.png' : 'assets/normal.png';
  }

  /// 점수에 따라 건강 위험도 계산
  /// 점수가 낮을수록 위험도가 높음
  static int calculateHealthRisk(int score) {
    if (score >= 60) {
      return 0; // 위험도 없음
    } else if (score >= 40) {
      return 10; // 10% 증가
    } else if (score >= 30) {
      return 25; // 25% 증가
    } else if (score >= 20) {
      return 40; // 40% 증가
    } else {
      return 60; // 60% 증가
    }
  }

  /// 건강 위험도 메시지 생성
  static String getHealthRiskMessage(int score) {
    final risk = calculateHealthRisk(score);
    if (risk == 0) {
      return '현재 건강한 식습관을 유지하고 있습니다!';
    }
    return '현재 고혈압 위험도 $risk% 증가';
  }

  /// 건강 위험도가 있는지 확인
  static bool hasHealthRisk(int score) {
    return calculateHealthRisk(score) > 0;
  }
}

