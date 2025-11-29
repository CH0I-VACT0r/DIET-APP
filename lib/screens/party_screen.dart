import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/party_provider.dart';
import '../models/friend_model.dart';
import '../utils/character_utils.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 시 샘플 데이터 로드 (실제로는 서버에서 가져옴)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final partyProvider = Provider.of<PartyProvider>(context, listen: false);
      if (partyProvider.friends.isEmpty) {
        partyProvider.initializeSampleData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파티원'),
        centerTitle: true,
      ),
      body: Consumer<PartyProvider>(
        builder: (context, partyProvider, child) {
          final friends = partyProvider.friends;

          if (friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 파티원이 없습니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 친구 추가 기능
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('친구 추가 기능은 준비 중입니다.'),
                        ),
                      );
                    },
                    child: const Text('친구 추가하기'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildFriendItem(friend, partyProvider);
            },
          );
        },
      ),
    );
  }

  /// 친구 아이템 위젯
  Widget _buildFriendItem(FriendModel friend, PartyProvider partyProvider) {
    final isZombie = friend.isZombie;
    final characterImagePath = CharacterUtils.getCharacterImagePath(friend.healthScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isZombie ? Colors.red[300]! : Colors.transparent,
          width: isZombie ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: isZombie 
                ? Colors.red.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: isZombie ? 24 : 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 캐릭터 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[100],
                border: Border.all(
                  color: isZombie ? Colors.red[300]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  characterImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        isZombie
                            ? Icons.sentiment_very_dissatisfied
                            : Icons.sentiment_very_satisfied,
                        size: 30,
                        color: isZombie ? Colors.grey : Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 친구 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        friend.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      if (isZombie)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Text(
                            '좀비',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isZombie)
                    Text(
                      '${friend.name}님이 썩어가고 있습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      '건강 점수: ${friend.healthScore}점',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _getLastActiveText(friend.lastActiveAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            
            // 찌르기 버튼 (좀비 상태일 때만 활성화)
            if (isZombie)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton.icon(
                  onPressed: () => _handlePushFriend(friend, partyProvider),
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('찌르기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  /// 마지막 활동 시간 텍스트
  String _getLastActiveText(DateTime lastActiveAt) {
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${(difference.inDays / 7).floor()}주 전';
    }
  }

  /// 친구 찌르기 처리
  void _handlePushFriend(FriendModel friend, PartyProvider partyProvider) async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('찌르기'),
        content: Text('${friend.name}님에게 Push 알림을 보내시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('보내기'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await partyProvider.pushFriend(friend.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${friend.name}님에게 찌르기 알림을 보냈습니다!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

