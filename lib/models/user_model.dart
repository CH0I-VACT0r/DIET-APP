/// 사용자 모델
class UserModel {
  final String id;
  final String name;
  final int age;
  
  // 설문조사 항목
  final String occupation; // 직업 (대학생, 대학원생, 직장인, 취준생 등)
  final int weeklyEatingOutFrequency; // 1주일 외식 빈도
  final String livingSituation; // 주거형태 및 평소 생활
  final String dietaryHabits; // 평소 식생활 및 식단 구성
  final List<String> cookingTools; // 조리도구 (전자레인지, 에어프라이기 등)
  final int monthlyFoodBudget; // 식비 예산 마지노선 (원)
  final bool canUseFire; // 불 사용 가능 여부
  final String refrigeratorSize; // 냉장고 부피 (소/중/대)
  
  // 설문조사 결과 기반
  final String personaType; // 페르소나 유형
  final DateTime? surveyCompletedAt; // 설문 완료 시각
  
  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.occupation,
    required this.weeklyEatingOutFrequency,
    required this.livingSituation,
    required this.dietaryHabits,
    required this.cookingTools,
    required this.monthlyFoodBudget,
    required this.canUseFire,
    required this.refrigeratorSize,
    required this.personaType,
    this.surveyCompletedAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'occupation': occupation,
      'weeklyEatingOutFrequency': weeklyEatingOutFrequency,
      'livingSituation': livingSituation,
      'dietaryHabits': dietaryHabits,
      'cookingTools': cookingTools,
      'monthlyFoodBudget': monthlyFoodBudget,
      'canUseFire': canUseFire,
      'refrigeratorSize': refrigeratorSize,
      'personaType': personaType,
      'surveyCompletedAt': surveyCompletedAt?.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      occupation: json['occupation'] as String,
      weeklyEatingOutFrequency: json['weeklyEatingOutFrequency'] as int,
      livingSituation: json['livingSituation'] as String,
      dietaryHabits: json['dietaryHabits'] as String,
      cookingTools: List<String>.from(json['cookingTools'] as List),
      monthlyFoodBudget: json['monthlyFoodBudget'] as int,
      canUseFire: json['canUseFire'] as bool,
      refrigeratorSize: json['refrigeratorSize'] as String,
      personaType: json['personaType'] as String,
      surveyCompletedAt: json['surveyCompletedAt'] != null
          ? DateTime.parse(json['surveyCompletedAt'] as String)
          : null,
    );
  }

  /// 복사본 생성 (일부 필드만 업데이트)
  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? occupation,
    int? weeklyEatingOutFrequency,
    String? livingSituation,
    String? dietaryHabits,
    List<String>? cookingTools,
    int? monthlyFoodBudget,
    bool? canUseFire,
    String? refrigeratorSize,
    String? personaType,
    DateTime? surveyCompletedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      weeklyEatingOutFrequency: weeklyEatingOutFrequency ?? this.weeklyEatingOutFrequency,
      livingSituation: livingSituation ?? this.livingSituation,
      dietaryHabits: dietaryHabits ?? this.dietaryHabits,
      cookingTools: cookingTools ?? this.cookingTools,
      monthlyFoodBudget: monthlyFoodBudget ?? this.monthlyFoodBudget,
      canUseFire: canUseFire ?? this.canUseFire,
      refrigeratorSize: refrigeratorSize ?? this.refrigeratorSize,
      personaType: personaType ?? this.personaType,
      surveyCompletedAt: surveyCompletedAt ?? this.surveyCompletedAt,
    );
  }
}

