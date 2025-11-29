// lib/recommendation_page.dart

import 'dart:convert';
import 'dart:math'; // 랜덤 섞기용
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // json 파일 로드용
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // 쿠팡 링크 연결용
import 'product.dart';
import 'providers/user_provider.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  String currentPersona = 'meal_kit'; // 기본값

  List<Product> allProducts = [];
  List<List<Product>> recommendedSets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // 1. 앱 시작 시 내 페르소나 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userPersona = context.read<UserProvider>().persona;
      setState(() {
        if (userPersona == "편의점 마스터" || userPersona == "배달음식 VIP") {
          currentPersona = 'meal_kit';
        } else if (userPersona == "알뜰한 요리사") {
          currentPersona = 'bulk';
        } else if (userPersona == "건강한 미식가") {
          currentPersona = 'ingredient';
        }
        loadProductData();
      });
    });
  }

  // 2. 데이터 로드
  Future<void> loadProductData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/coupang_data.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        allProducts = data.map((json) => Product.fromJson(json)).toList();
        makeSets(); 
        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  // ★ [핵심 수정] 가격 안배를 고려한 세트 조합 알고리즘
  void makeSets() {
    // 1. 불량 데이터(0원) 제외
    List<Product> validProducts = allProducts.where((p) => p.price > 0).toList();
    List<Product> targetProducts = [];

    // 2. 페르소나별 상품 풀(Pool) 확보
    if (currentPersona == 'meal_kit') {
      targetProducts = validProducts.where((p) => p.type == 'meal_kit').toList();
    } else if (currentPersona == 'bulk') {
      targetProducts = validProducts.where((p) => 
          p.type == 'bulk' || (p.type == 'ingredient' && p.price <= 20000)
      ).toList();
    } else {
      targetProducts = validProducts.where((p) => p.type == 'ingredient').toList();
    }

    // 3. 메인(비싼거)과 서브(싼거) 분리
    // (기준: 15,000원 이상이면 메인, 아니면 서브)
    List<Product> mains = targetProducts.where((p) => p.price >= 15000).toList();
    List<Product> sides = targetProducts.where((p) => p.price < 15000).toList();

    // 셔플 (매번 다르게)
    mains.shuffle(Random());
    sides.shuffle(Random());

    // 4. 세트 조립: [메인 1개 + 서브 2개]
    List<List<Product>> newSets = [];
    
    // 메인이 있는 만큼 세트를 만듦
    for (var main in mains) {
      if (sides.length >= 2) {
        // 서브에서 2개 뽑기
        Product side1 = sides.removeAt(0); // 뽑고 리스트에서 제거 (중복 방지)
        Product side2 = sides.removeAt(0);
        
        newSets.add([main, side1, side2]);
      } else {
        break; // 서브가 부족하면 그만 만듦
      }
    }

    // 만약 세트가 너무 적게 만들어졌으면(3개 미만), 남은 걸로라도 만듦
    if (newSets.length < 2 && targetProducts.isNotEmpty) {
       // 그냥 무작위로 3개씩 묶어서 추가 (fallback)
       List<Product> leftovers = [...mains, ...sides]..shuffle();
       for (int i = 0; i < leftovers.length; i += 3) {
         if(i + 3 <= leftovers.length) newSets.add(leftovers.sublist(i, i+3));
       }
    }

    setState(() {
      recommendedSets = newSets;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  // ★ [추가] 구매 링크 팝업 띄우기 (장바구니 대용)
  void _showPurchaseDialog(List<Product> products) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🛍️ 구매 링크 모음", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("쿠팡 장바구니에 하나씩 담아주세요!", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (p.imageUrl.isNotEmpty && !p.imageUrl.contains('placeholder'))
                            ? Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.shopping_cart)),
                      ),
                      title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: ElevatedButton(
                        onPressed: () => _launchUrl(p.purchaseUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          minimumSize: const Size(60, 30)
                        ),
                        child: const Text("담기"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getPersonaTitle() {
    switch (currentPersona) {
      case 'meal_kit': return '⏰ 시간 부족형';
      case 'bulk': return '💰 절약형';
      case 'ingredient': return '👨‍🍳 요리형';
      default: return '맞춤 추천';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 맞춤 식단 세트'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 상단 페르소나 변경 버튼
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTypeButton('시간부족', 'meal_kit'),
                _buildTypeButton('절약형', 'bulk'),
                _buildTypeButton('요리형', 'ingredient'),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : recommendedSets.isEmpty
                    ? const Center(child: Text("추천할 상품 조합이 부족합니다."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: recommendedSets.length,
                        itemBuilder: (context, index) {
                          final setProducts = recommendedSets[index];
                          int setPrice = setProducts.fold(0, (sum, item) => sum + item.price);
                          int setKcal = setProducts.fold(0, (sum, item) => sum + item.kcal);

                          return _buildSetCard(index, setProducts, setPrice, setKcal);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(int index, List<Product> products, int totalPrice, int totalKcal) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 세트 헤더
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("주간 추천 세트 ${String.fromCharCode(65 + index)}", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("총 ${products.length}개 상품 | 약 $totalKcal kcal", 
                        style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
                Text(
                  "₩${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),

          // 2. 상품 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final product = products[i];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (product.imageUrl.isEmpty || product.imageUrl.contains('placeholder'))
                      ? const Icon(Icons.restaurant, color: Colors.grey)
                      : Image.network(product.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey)),
                ),
                title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text("${product.price}원"),
                trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
              );
            },
          ),

          // 3. 구매 팝업 버튼 (수정됨)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () => _showPurchaseDialog(products), // 팝업 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("이 세트 구매하기 (링크 모음)"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String title, String type) {
    bool isSelected = currentPersona == type;
    return InkWell(
      onTap: () {
        setState(() {
          currentPersona = type;
          makeSets();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}