/// 식단 기록 모델
class DietRecordModel {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final List<String> foods;
  final Map<String, double> nutrition; // 영양소 정보

  DietRecordModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foods,
    required this.nutrition,
  });
}

