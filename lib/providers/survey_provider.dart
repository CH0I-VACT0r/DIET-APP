import 'package:flutter/foundation.dart';
import '../models/survey_question_model.dart';
import '../utils/survey_questions.dart';

class SurveyProvider with ChangeNotifier {
  final List<SurveyQuestion> _questions = SurveyQuestions.getQuestions();
  final Map<String, dynamic> _answers = {};
  int _currentPageIndex = 0;
  bool _isCompleted = false;

  List<SurveyQuestion> get questions => _questions;
  Map<String, dynamic> get answers => _answers;
  int get currentPageIndex => _currentPageIndex;
  bool get isCompleted => _isCompleted;
  int get totalQuestions => _questions.length;

  /// 현재 질문 가져오기
  SurveyQuestion? getCurrentQuestion() {
    if (_currentPageIndex >= 0 && _currentPageIndex < _questions.length) {
      return _questions[_currentPageIndex];
    }
    return null;
  }

  /// 답변 저장
  void setAnswer(String questionId, dynamic answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  /// 현재 질문의 답변 가져오기
  dynamic getAnswer(String questionId) {
    return _answers[questionId];
  }

  /// 다음 페이지로 이동
  void nextPage() {
    if (_currentPageIndex < _questions.length - 1) {
      _currentPageIndex++;
      notifyListeners();
    } else {
      // 마지막 질문이면 완료 처리
      completeSurvey();
    }
  }

  /// 이전 페이지로 이동
  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }

  /// 특정 페이지로 이동
  void goToPage(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  /// 설문 완료
  void completeSurvey() {
    _isCompleted = true;
    notifyListeners();
  }

  /// 설문 점수 계산
  int calculateScore() {
    int score = 0;

    // 각 답변에 따라 점수 부여
    for (var entry in _answers.entries) {
      final questionId = entry.key;
      final answer = entry.value;

      switch (questionId) {
        case 'eating_out_frequency':
          // 외식 빈도가 낮을수록 높은 점수
          final options = ['0회', '1-2회', '3-4회', '5-6회', '7회 이상'];
          final index = options.indexOf(answer.toString());
          score += (options.length - index) * 2;
          break;

        case 'delivery_frequency':
          // 배달 빈도가 낮을수록 높은 점수
          final options = ['0회', '1-2회', '3-4회', '5-6회', '7회 이상'];
          final index = options.indexOf(answer.toString());
          score += (options.length - index) * 2;
          break;

        case 'dietary_habits':
          // 규칙적인 식사가 높은 점수
          if (answer == '규칙적으로 3끼 챙겨먹음') {
            score += 10;
          } else if (answer == '아침 결식이 많음') {
            score += 5;
          } else if (answer == '간편식 위주') {
            score += 3;
          } else if (answer == '불규칙하게 먹음') {
            score += 2;
          }
          break;

        case 'cooking_tools':
          // 조리도구가 많을수록 높은 점수
          if (answer is List) {
            score += answer.length * 2;
          }
          break;

        case 'can_use_fire':
          // 불 사용 가능하면 높은 점수
          if (answer == true) {
            score += 5;
          }
          break;

        case 'refrigerator_size':
          // 냉장고가 클수록 높은 점수
          if (answer == '대형') {
            score += 5;
          } else if (answer == '중형') {
            score += 3;
          } else if (answer == '소형') {
            score += 1;
          }
          break;
      }
    }

    return score;
  }

  /// 페르소나 유형 결정
  String determinePersonaType() {
    final score = calculateScore();
    final occupation = _answers['occupation']?.toString() ?? '';
    final budget = _answers['monthly_food_budget']?.toString() ?? '';

    // 점수와 상황에 따라 페르소나 결정
    if (score >= 40) {
      return '건강한 식습관 유지형';
    } else if (score >= 25) {
      return '개선 가능형';
    } else if (occupation.contains('대학') && budget.contains('10-20') || budget.contains('10만원 미만')) {
      return '가성비 추구형';
    } else if (score < 15) {
      return '개선 필요형';
    } else {
      return '일반형';
    }
  }

  /// 설문 결과 생성
  SurveyResult getSurveyResult(String userId) {
    return SurveyResult(
      userId: userId,
      responses: _answers.entries.map((entry) {
        return SurveyResponse(
          questionId: entry.key,
          answer: entry.value,
        );
      }).toList(),
      completedAt: DateTime.now(),
      personaType: determinePersonaType(),
    );
  }

  /// 초기화
  void reset() {
    _answers.clear();
    _currentPageIndex = 0;
    _isCompleted = false;
    notifyListeners();
  }
}

