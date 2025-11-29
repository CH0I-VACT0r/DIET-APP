/// 친구 모델
class FriendModel {
  final String id;
  final String name;
  final int healthScore; // 건강 점수
  final String? avatarUrl; // 프로필 이미지 URL
  final DateTime lastActiveAt; // 마지막 활동 시간

  FriendModel({
    required this.id,
    required this.name,
    required this.healthScore,
    this.avatarUrl,
    required this.lastActiveAt,
  });

  /// 좀비 상태인지 확인
  bool get isZombie => healthScore < 30;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'healthScore': healthScore,
      'avatarUrl': avatarUrl,
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as String,
      name: json['name'] as String,
      healthScore: json['healthScore'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    );
  }

  /// 복사본 생성
  FriendModel copyWith({
    String? id,
    String? name,
    int? healthScore,
    String? avatarUrl,
    DateTime? lastActiveAt,
  }) {
    return FriendModel(
      id: id ?? this.id,
      name: name ?? this.name,
      healthScore: healthScore ?? this.healthScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

