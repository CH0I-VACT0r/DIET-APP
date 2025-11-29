import 'package:flutter/foundation.dart';
import '../models/friend_model.dart';

/// 파티(친구 그룹) 상태 관리 Provider
class PartyProvider with ChangeNotifier {
  List<FriendModel> _friends = [];

  List<FriendModel> get friends => _friends;
  
  /// 좀비 상태인 친구들만 필터링
  List<FriendModel> get zombieFriends => _friends.where((f) => f.isZombie).toList();

  /// 친구 추가
  void addFriend(FriendModel friend) {
    _friends.add(friend);
    notifyListeners();
  }

  /// 친구 제거
  void removeFriend(String friendId) {
    _friends.removeWhere((f) => f.id == friendId);
    notifyListeners();
  }

  /// 친구 점수 업데이트
  void updateFriendScore(String friendId, int newScore) {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      _friends[index] = _friends[index].copyWith(healthScore: newScore);
      notifyListeners();
    }
  }

  /// 친구에게 찌르기 (Push 알림 전송)
  Future<void> pushFriend(String friendId) async {
    final friend = _friends.firstWhere((f) => f.id == friendId);
    
    // TODO: 실제 Push 알림 전송 로직 구현
    // 여기서는 시뮬레이션만 수행
    
    if (kDebugMode) {
      print('${friend.name}님에게 찌르기 알림 전송');
    }
    
    // 찌르기 후 친구의 점수를 약간 증가시킬 수 있음 (동기부여)
    // updateFriendScore(friendId, friend.healthScore + 1);
  }

  /// 초기 샘플 데이터 생성 (테스트용)
  void initializeSampleData() {
    _friends = [
      FriendModel(
        id: '1',
        name: '김철수',
        healthScore: 25, // 좀비 상태
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FriendModel(
        id: '2',
        name: '이영희',
        healthScore: 45, // 정상 상태
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      FriendModel(
        id: '3',
        name: '박민수',
        healthScore: 20, // 좀비 상태
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      FriendModel(
        id: '4',
        name: '정수진',
        healthScore: 55, // 정상 상태
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      FriendModel(
        id: '5',
        name: '최동현',
        healthScore: 15, // 좀비 상태
        lastActiveAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    notifyListeners();
  }
}

