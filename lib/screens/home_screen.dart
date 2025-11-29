import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/nutrition_provider.dart';
import '../providers/character_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  // ignore: unused_field
  File? _selectedImage; // 선택된 이미지 (나중에 사용 가능)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건강한 식습관'),
        centerTitle: true,
      ),
      body: Consumer2<CharacterProvider, NutritionProvider>(
        builder: (context, characterProvider, nutritionProvider, child) {
          final characterImagePath = characterProvider.characterImagePath;
          final isZombie = characterProvider.characterState == 'zombie';
          final nutritionData = nutritionProvider.nutritionData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // 캐릭터 상태 표시
                _buildCharacterSection(characterImagePath, isZombie, characterProvider.score),
                
                const SizedBox(height: 32),
                
                // 영양소 방사형 그래프
                _buildNutritionRadarChart(nutritionData),
                
                const SizedBox(height: 32),
                
                // 식단 기록하기 버튼
                _buildRecordButton(),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 캐릭터 섹션
  Widget _buildCharacterSection(String imagePath, bool isZombie, int score) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '내 캐릭터',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isZombie
                                ? Icons.sentiment_very_dissatisfied
                                : Icons.sentiment_very_satisfied,
                            size: 80,
                            color: isZombie
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isZombie ? '좀비 상태' : '건강한 상태',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isZombie ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isZombie ? Colors.red[300]! : Colors.green[300]!,
                ),
              ),
              child: Text(
                isZombie ? '⚠️ 좀비 상태' : '✅ 건강한 상태',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isZombie ? Colors.red[900] : Colors.green[900],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '점수: $score점',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// 영양소 방사형 그래프
  Widget _buildNutritionRadarChart(NutritionData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '오늘의 영양소',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              height: 300,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      borderColor: Theme.of(context).colorScheme.primary,
                      borderWidth: 2,
                      dataEntries: [
                        RadarEntry(value: data.carbohydrates),
                        RadarEntry(value: data.protein),
                        RadarEntry(value: data.fat),
                        RadarEntry(value: data.vitamins),
                        RadarEntry(value: data.water),
                      ],
                    ),
                  ],
                  radarBorderData: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  tickBorderData: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  gridBorderData: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  titlePositionPercentageOffset: 0.15,
                  getTitle: (index, angle) {
                    const titles = ['탄수화물', '단백질', '지방', '비타민', '수분'];
                    return RadarChartTitle(
                      text: titles[index],
                      angle: angle,
                    );
                  },
                  tickCount: 4,
                  ticksTextStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 영양소 수치 표시
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildNutritionLabel('탄수화물', data.carbohydrates),
                _buildNutritionLabel('단백질', data.protein),
                _buildNutritionLabel('지방', data.fat),
                _buildNutritionLabel('비타민', data.vitamins),
                _buildNutritionLabel('수분', data.water),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// 영양소 라벨
  Widget _buildNutritionLabel(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: ${value.toInt()}%',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  /// 식단 기록하기 버튼
  Widget _buildRecordButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showImageSourceDialog,
        icon: const Icon(Icons.camera_alt),
        label: const Text('식단 기록하기'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// 이미지 소스 선택 다이얼로그
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('식단 기록'),
        content: const Text('사진을 어떻게 가져오시겠어요?'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('카메라로 촬영'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('갤러리에서 선택'),
          ),
        ],
      ),
    );
  }

  /// 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // 이미지 선택 후 처리 (예: 영양소 분석)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('식단 사진이 선택되었습니다. 분석 중...'),
              duration: Duration(seconds: 2),
            ),
          );
          
          // TODO: 실제 영양소 분석 로직 구현
          // 여기서는 예시로 랜덤 값으로 업데이트
          _simulateNutritionAnalysis();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 영양소 분석 시뮬레이션 (실제 구현 시 API 호출로 대체)
  void _simulateNutritionAnalysis() {
    final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);
    final characterProvider = Provider.of<CharacterProvider>(context, listen: false);
    
    // 랜덤 영양소 값 생성 (실제로는 이미지 분석 결과)
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    nutritionProvider.updateNutrition(
      carbohydrates: (random * 0.8).clamp(0, 100).toDouble(),
      protein: (random * 0.7).clamp(0, 100).toDouble(),
      fat: (random * 0.6).clamp(0, 100).toDouble(),
      vitamins: (random * 0.5).clamp(0, 100).toDouble(),
      water: (random * 0.9).clamp(0, 100).toDouble(),
    );
    
    // 영양소가 좋으면 점수 증가, 나쁘면 감소
    final avgNutrition = (
      nutritionProvider.nutritionData.carbohydrates +
      nutritionProvider.nutritionData.protein +
      nutritionProvider.nutritionData.fat +
      nutritionProvider.nutritionData.vitamins +
      nutritionProvider.nutritionData.water
    ) / 5;
    
    if (avgNutrition > 60) {
      characterProvider.increaseScore(5);
    } else if (avgNutrition < 40) {
      characterProvider.decreaseScore(5);
    }
  }
}
