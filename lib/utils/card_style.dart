import 'package:flutter/material.dart';

/// 힙한 카드 스타일 유틸리티
class CardStyle {
  /// 부드러운 그림자가 있는 컨테이너 데코레이션
  static BoxDecoration getSoftShadowDecoration({
    Color? color,
    double borderRadius = 28,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// 더 강한 그림자가 있는 컨테이너 데코레이션
  static BoxDecoration getStrongShadowDecoration({
    Color? color,
    double borderRadius = 28,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? Colors.black).withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// 버튼 그림자 데코레이션
  static BoxDecoration getButtonShadowDecoration({
    required Color shadowColor,
    double borderRadius = 28,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

