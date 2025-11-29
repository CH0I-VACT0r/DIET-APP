/// 설문조사 질문 모델
class SurveyQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String>? options; // 선택형 질문의 경우 옵션 리스트
  final bool isRequired; // 필수 질문 여부
  final int order; // 질문 순서

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.isRequired = true,
    required this.order,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type.toString().split('.').last,
      'options': options,
      'isRequired': isRequired,
      'order': order,
    };
  }

  /// JSON에서 생성
  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.text,
      ),
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      isRequired: json['isRequired'] as bool? ?? true,
      order: json['order'] as int,
    );
  }
}

/// 질문 유형
enum QuestionType {
  text, // 텍스트 입력
  singleChoice, // 단일 선택
  multipleChoice, // 다중 선택
  number, // 숫자 입력
  boolean, // 예/아니오
}

/// 설문조사 응답 모델
class SurveyResponse {
  final String questionId;
  final dynamic answer; // 질문 유형에 따라 String, int, bool, List<String> 등

  SurveyResponse({
    required this.questionId,
    required this.answer,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }

  /// JSON에서 생성
  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      questionId: json['questionId'] as String,
      answer: json['answer'],
    );
  }
}

/// 설문조사 결과 모델
class SurveyResult {
  final String userId;
  final List<SurveyResponse> responses;
  final DateTime completedAt;
  final String? personaType; // 설문 결과 기반 페르소나 유형

  SurveyResult({
    required this.userId,
    required this.responses,
    required this.completedAt,
    this.personaType,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'responses': responses.map((r) => r.toJson()).toList(),
      'completedAt': completedAt.toIso8601String(),
      'personaType': personaType,
    };
  }

  /// JSON에서 생성
  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    return SurveyResult(
      userId: json['userId'] as String,
      responses: (json['responses'] as List)
          .map((r) => SurveyResponse.fromJson(r as Map<String, dynamic>))
          .toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      personaType: json['personaType'] as String?,
    );
  }
}

