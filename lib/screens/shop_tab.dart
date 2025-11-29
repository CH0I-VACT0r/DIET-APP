import 'package:flutter/material.dart';
import '../recommendation_page.dart'; // <-- 우리가 만든 추천 페이지 불러오기

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 껍데기(ShopTab)는 그대로 두고, 알맹이(RecommendationPage)만 보여줍니다.
    return const RecommendationPage();
  }
}