import '../models/survey_question_model.dart';

/// 설문조사 질문 목록
class SurveyQuestions {
  static List<SurveyQuestion> getQuestions() {
    return [
      SurveyQuestion(
        id: 'occupation',
        question: '직업을 선택해주세요',
        type: QuestionType.singleChoice,
        options: ['대학생', '대학원생', '직장인', '취준생', '기타'],
        order: 1,
      ),
      SurveyQuestion(
        id: 'eating_out_frequency',
        question: '1주일에 몇 번 외식을 하시나요?',
        type: QuestionType.singleChoice,
        options: ['0회', '1-2회', '3-4회', '5-6회', '7회 이상'],
        order: 2,
      ),
      SurveyQuestion(
        id: 'delivery_frequency',
        question: '1주일에 몇 번 배달을 주문하시나요?',
        type: QuestionType.singleChoice,
        options: ['0회', '1-2회', '3-4회', '5-6회', '7회 이상'],
        order: 3,
      ),
      SurveyQuestion(
        id: 'living_situation',
        question: '주거형태 및 평소 생활을 선택해주세요',
        type: QuestionType.singleChoice,
        options: [
          '기숙사',
          '원룸/오피스텔',
          '하숙/고시원',
          '자취방',
          '기타',
        ],
        order: 4,
      ),
      SurveyQuestion(
        id: 'dietary_habits',
        question: '평소 식생활 및 식단 구성을 선택해주세요',
        type: QuestionType.singleChoice,
        options: [
          '규칙적으로 3끼 챙겨먹음',
          '아침 결식이 많음',
          '간편식 위주',
          '불규칙하게 먹음',
          '다이어트 중',
        ],
        order: 5,
      ),
      SurveyQuestion(
        id: 'cooking_tools',
        question: '보유한 조리도구를 모두 선택해주세요',
        type: QuestionType.multipleChoice,
        options: [
          '전자레인지',
          '에어프라이기',
          '인덕션/가스레인지',
          '전기밥솥',
          '오븐',
          '없음',
        ],
        order: 6,
      ),
      SurveyQuestion(
        id: 'can_use_fire',
        question: '불 사용이 가능한가요?',
        type: QuestionType.boolean,
        order: 7,
      ),
      SurveyQuestion(
        id: 'refrigerator_size',
        question: '냉장고 크기를 선택해주세요',
        type: QuestionType.singleChoice,
        options: ['소형', '중형', '대형'],
        order: 8,
      ),
      SurveyQuestion(
        id: 'monthly_food_budget',
        question: '한 달 식비 예산은 얼마인가요?',
        type: QuestionType.singleChoice,
        options: [
          '10만원 미만',
          '10-20만원',
          '20-30만원',
          '30-40만원',
          '40만원 이상',
        ],
        order: 9,
      ),
    ];
  }
}

