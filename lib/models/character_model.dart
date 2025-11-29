/// 캐릭터 모델
class CharacterModel {
  final String id;
  final String userId;
  final String name;
  final int level;
  final int experience;
  final String mood; // 'happy', 'sad', 'normal'
  final String state; // 'zombie', 'normal' - 점수에 따라 결정
  final Map<String, dynamic> customization;

  CharacterModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.level,
    required this.experience,
    required this.mood,
    required this.state,
    required this.customization,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'level': level,
      'experience': experience,
      'mood': mood,
      'state': state,
      'customization': customization,
    };
  }

  /// JSON에서 생성
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      experience: json['experience'] as int,
      mood: json['mood'] as String,
      state: json['state'] as String? ?? 'normal',
      customization: json['customization'] as Map<String, dynamic>,
    );
  }

  /// 복사본 생성
  CharacterModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? level,
    int? experience,
    String? mood,
    String? state,
    Map<String, dynamic>? customization,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      mood: mood ?? this.mood,
      state: state ?? this.state,
      customization: customization ?? this.customization,
    );
  }
}

