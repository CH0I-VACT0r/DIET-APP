import 'package:flutter/foundation.dart';

/// 영양소 데이터 모델
class NutritionData {
  final double carbohydrates; // 탄수화물 (0-100)
  final double protein; // 단백질 (0-100)
  final double fat; // 지방 (0-100)
  final double vitamins; // 비타민 (0-100)
  final double water; // 수분 (0-100)

  NutritionData({
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.vitamins,
    required this.water,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'carbohydrates': carbohydrates,
      'protein': protein,
      'fat': fat,
      'vitamins': vitamins,
      'water': water,
    };
  }

  /// JSON에서 생성
  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      vitamins: (json['vitamins'] as num).toDouble(),
      water: (json['water'] as num).toDouble(),
    );
  }
}

/// 영양소 상태 관리 Provider
class NutritionProvider with ChangeNotifier {
  NutritionData _nutritionData = NutritionData(
    carbohydrates: 60.0,
    protein: 50.0,
    fat: 40.0,
    vitamins: 30.0,
    water: 70.0,
  );

  NutritionData get nutritionData => _nutritionData;

  /// 영양소 데이터 업데이트
  void updateNutritionData(NutritionData data) {
    _nutritionData = data;
    notifyListeners();
  }

  /// 특정 영양소 업데이트
  void updateNutrition({
    double? carbohydrates,
    double? protein,
    double? fat,
    double? vitamins,
    double? water,
  }) {
    _nutritionData = NutritionData(
      carbohydrates: carbohydrates ?? _nutritionData.carbohydrates,
      protein: protein ?? _nutritionData.protein,
      fat: fat ?? _nutritionData.fat,
      vitamins: vitamins ?? _nutritionData.vitamins,
      water: water ?? _nutritionData.water,
    );
    notifyListeners();
  }
}

