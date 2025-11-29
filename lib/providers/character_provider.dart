import 'package:flutter/foundation.dart';
import '../utils/character_utils.dart';

/// 캐릭터 상태 관리 Provider
class CharacterProvider with ChangeNotifier {
  int _score = 50; // 기본 점수

  int get score => _score;
  String get characterState => CharacterUtils.getCharacterState(_score);
  String get characterImagePath => CharacterUtils.getCharacterImagePath(_score);

  /// 점수 업데이트
  void updateScore(int newScore) {
    _score = newScore;
    notifyListeners();
  }

  /// 점수 증가
  void increaseScore(int amount) {
    _score = (_score + amount).clamp(0, 100);
    notifyListeners();
  }

  /// 점수 감소
  void decreaseScore(int amount) {
    _score = (_score - amount).clamp(0, 100);
    notifyListeners();
  }
}

