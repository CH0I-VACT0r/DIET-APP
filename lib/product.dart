// lib/product.dart

class Product {
  final String id;
  final String name;
  final int price;
  final String type; // meal_kit, bulk, ingredient
  final String imageUrl;
  final String purchaseUrl;
  final int kcal;
  final int protein;
  final int cookingTime;
  final int difficulty;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.imageUrl,
    required this.purchaseUrl,
    required this.kcal,
    required this.protein,
    required this.cookingTime,
    required this.difficulty,
  });

  // JSON 데이터를 Dart 객체로 변환하는 생성자
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['name'] ?? '상품명 없음',
      price: json['price'] ?? 0,
      type: json['type'] ?? 'ingredient',
      imageUrl: json['image_url'] ?? '',
      purchaseUrl: json['purchase_url'] ?? '',
      kcal: json['kcal'] ?? 0,
      protein: json['protein'] ?? 0,
      cookingTime: json['cooking_time'] ?? 0,
      difficulty: json['difficulty'] ?? 0,
    );
  }
}