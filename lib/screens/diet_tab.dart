import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DietTab extends StatefulWidget {
  const DietTab({super.key});

  @override
  State<DietTab> createState() => _DietTabState();
}

class _DietTabState extends State<DietTab> {
  DateTime? _expandedDate; 

  // ★ [복구] 카테고리 대신 '즐겨찾기' 리스트 유지 (데이터가 확실한 것들)
  final List<String> _favorites = ["현미밥", "달걀부침", "김치찌개", "라면", "닭가슴살"];

  final Map<String, double> _rdi = {
    'kcal': 2500, 'carbo': 324, 'protein': 55, 'fat': 54,
    'vit_c': 100, 'calcium': 700, 'sodium': 2000, 'trans_fat': 0.5,
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _expandedDate = DateTime.now();
  }

  String _getDateString(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  
  DateTime get _monday {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }
  DateTime get _sunday => _monday.add(const Duration(days: 6));

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('diet_logs')
        .where('date', isGreaterThanOrEqualTo: _getDateString(_monday))
        .where('date', isLessThanOrEqualTo: _getDateString(_sunday));

    return Scaffold(
      appBar: AppBar(title: const Text("식단 다이어리 🥗"), centerTitle: true, elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("오류 발생"));
          final docs = snapshot.data?.docs ?? [];

          // 데이터 가공
          Map<String, List<QueryDocumentSnapshot>> logsByDate = {};
          Map<String, Map<String, double>> statsByDate = {};
          Map<String, double> dailyKcal = {};
          Map<String, double> weeklyNutrients = {
            'carbo': 0, 'protein': 0, 'fat': 0, 'vit_c': 0, 'calcium': 0
          };

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            String date = data['date'];
            
            if (!logsByDate.containsKey(date)) logsByDate[date] = [];
            logsByDate[date]!.add(doc);

            if (!statsByDate.containsKey(date)) statsByDate[date] = _initNutrients();
            
            _rdi.keys.forEach((key) {
              double val = double.tryParse(data[key]?.toString() ?? "0") ?? 0;
              statsByDate[date]![key] = (statsByDate[date]![key] ?? 0) + val;
              if (weeklyNutrients.containsKey(key)) {
                weeklyNutrients[key] = (weeklyNutrients[key] ?? 0) + val;
              }
            });
          }

          statsByDate.forEach((key, value) {
            dailyKcal[key] = value['kcal'] ?? 0;
          });

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildWeeklyAnalysisCard(dailyKcal, weeklyNutrients),
                const SizedBox(height: 20),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    DateTime day = _monday.add(Duration(days: index));
                    String dateKey = _getDateString(day);
                    
                    bool isExpanded = _expandedDate != null && _getDateString(_expandedDate!) == dateKey;
                    bool isToday = _getDateString(DateTime.now()) == dateKey;

                    return _buildDailyCard(
                      day, 
                      isExpanded, 
                      isToday,
                      logsByDate[dateKey] ?? [], 
                      statsByDate[dateKey] ?? _initNutrients()
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 위젯 빌더 ---

  Widget _buildWeeklyAnalysisCard(Map<String, double> dailyKcal, Map<String, double> weeklyNutrients) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("주간 식단 리포트 📊", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildWeeklyBarGraph(dailyKcal)),
              const SizedBox(width: 15),
              Container(width: 1, height: 120, color: Colors.grey[200]),
              const SizedBox(width: 15),
              Expanded(flex: 4, child: _buildDeficientNutrients(weeklyNutrients)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarGraph(Map<String, double> dailyKcal) {
    double maxKcal = _rdi['kcal']!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        DateTime day = _monday.add(Duration(days: index));
        String dateKey = _getDateString(day);
        double currentKcal = dailyKcal[dateKey] ?? 0;
        double percent = (currentKcal / maxKcal).clamp(0.0, 1.0);
        bool isToday = day.day == DateTime.now().day;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(width: 8, height: 80, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                Container(
                  width: 8,
                  height: 80 * percent,
                  decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(DateFormat('E', 'ko_KR').format(day),
                style: TextStyle(fontSize: 10, color: isToday ? Colors.blue : Colors.grey, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
          ],
        );
      }),
    );
  }

  Widget _buildDeficientNutrients(Map<String, double> weeklyTotal) {
    Map<String, double> percentages = {};
    weeklyTotal.forEach((key, val) {
      if (_rdi.containsKey(key)) {
        percentages[key] = val / (_rdi[key]! * 7);
      }
    });

    var sortedKeys = percentages.keys.toList()..sort((a, b) => percentages[a]!.compareTo(percentages[b]!));
    var lacking = sortedKeys.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("부족해요! 💊", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        const SizedBox(height: 10),
        if (lacking.isEmpty)
          const Text("완벽해요!", style: TextStyle(fontSize: 12))
        else
          ...lacking.map((key) {
            String name = _getNutrientName(key);
            int pct = (percentages[key]! * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Icon(Icons.arrow_downward, size: 12, color: Colors.red[300]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text("$name ${pct}%", 
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDailyCard(
    DateTime day, 
    bool isExpanded, 
    bool isToday,
    List<QueryDocumentSnapshot> dayLogs, 
    Map<String, double> dayStats
  ) {
    Color headerColor = isExpanded ? Colors.blue[50]! : Colors.white;
    Color dateColor = isToday ? Colors.blue : Colors.black;
    double kcal = dayStats['kcal'] ?? 0;

    Map<String, bool> hasMeal = {'breakfast': false, 'lunch': false, 'dinner': false};
    Map<String, List<Map<String, dynamic>>> sortedMeals = {'breakfast': [], 'lunch': [], 'dinner': []};

    for (var doc in dayLogs) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      String type = data['mealType'];
      if (sortedMeals.containsKey(type)) {
        sortedMeals[type]!.add(data);
        hasMeal[type] = true;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), 
        side: isToday ? const BorderSide(color: Colors.blue, width: 1.5) : BorderSide.none),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDate = null;
                } else {
                  _expandedDate = day;
                }
              });
            },
            tileColor: headerColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: const Radius.circular(15), bottom: Radius.circular(isExpanded ? 0 : 15))),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${day.month}/${day.day}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 12)),
                Text(DateFormat('E', 'ko_KR').format(day), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            title: Text(
              "${kcal.toInt()} kcal", 
              style: TextStyle(fontWeight: FontWeight.bold, color: dateColor, fontSize: 16)
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMealIcon(Icons.wb_twilight, hasMeal['breakfast']!, Colors.orange), // 아침
                const SizedBox(width: 8),
                _buildMealIcon(Icons.wb_sunny, hasMeal['lunch']!, Colors.redAccent),     // 점심
                const SizedBox(width: 8),
                _buildMealIcon(Icons.nights_stay, hasMeal['dinner']!, Colors.indigo),    // 저녁
                const SizedBox(width: 10),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),

          if (isExpanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _buildNutrientDashboard(dayStats), 
                  const SizedBox(height: 20),
                  _buildMealSection("아침", "breakfast", sortedMeals['breakfast']!, day),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider()),
                  _buildMealSection("점심", "lunch", sortedMeals['lunch']!, day),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider()),
                  _buildMealSection("저녁", "dinner", sortedMeals['dinner']!, day),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealIcon(IconData icon, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: isActive ? activeColor : Colors.grey[300]),
    );
  }

  Widget _buildNutrientDashboard(Map<String, double> total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMacroNutrientCircle("탄수화물", total['carbo']!, _rdi['carbo']!, Colors.purple)),
              Expanded(child: _buildMacroNutrientCircle("단백질", total['protein']!, _rdi['protein']!, Colors.blue)),
              Expanded(child: _buildMacroNutrientCircle("지방", total['fat']!, _rdi['fat']!, Colors.orange)),
            ],
          ),
          const SizedBox(height: 15),
          _buildMicroNutrientBar("나트륨", total['sodium']!, _rdi['sodium']!, "mg", isLimit: true),
        ],
      ),
    );
  }

  Widget _buildMealSection(String label, String mealKey, List<Map<String, dynamic>> mealLogs, DateTime targetDate) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    mealKey == 'breakfast' ? Icons.wb_twilight : (mealKey == 'lunch' ? Icons.wb_sunny : Icons.nights_stay),
                    size: 20, color: Colors.grey
                  ),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showInputModal(mealKey, targetDate),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("메뉴추가"),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              )
            ],
          ),
          const SizedBox(height: 10),
          
          if (mealLogs.isEmpty)
            const Text("기록된 식단이 없습니다.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            Column(
              children: mealLogs.map((log) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    if (log['imagePath'] != null && log['imagePath'].isNotEmpty)
                      Container(
                        width: 40, height: 40,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(log['imagePath'])),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                    Expanded(child: Text(log['foodName'], style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text("${log['kcal']}kcal", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => _deleteLog(log['id']),
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    )
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Map<String, double> _initNutrients() {
    return {'kcal': 0, 'carbo': 0, 'protein': 0, 'fat': 0, 'vit_c': 0, 'calcium': 0, 'sodium': 0, 'trans_fat': 0};
  }

  String _getNutrientName(String key) {
    switch(key) {
      case 'carbo': return '탄수화물';
      case 'protein': return '단백질';
      case 'fat': return '지방';
      case 'vit_c': return '비타민C';
      case 'calcium': return '칼슘';
      case 'sodium': return '나트륨';
      case 'trans_fat': return '트랜스지방';
      default: return key;
    }
  }

  Widget _buildMacroNutrientCircle(String label, double current, double goal, Color color) {
    double percent = goal == 0 ? 0 : (current / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 40, height: 40,
          child: CircularProgressIndicator(value: percent, color: color, backgroundColor: Colors.grey[200], strokeWidth: 4),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text("${current.toInt()}g", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMicroNutrientBar(String label, double current, double goal, String unit, {bool isLimit = false}) {
    double percent = goal == 0 ? 0 : (current / goal).clamp(0.0, 1.0);
    Color barColor = isLimit && percent >= 1.0 ? Colors.red : Colors.green;
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        Expanded(
          child: LinearProgressIndicator(value: percent, color: barColor, backgroundColor: Colors.grey[200], minHeight: 6, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        Text("${current.toInt()}/$goal$unit", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ★ [수정] 모달창: 헤더 포맷 변경, 사진 버튼 추가, 즐겨찾기(Favorites) 복구
  void _showInputModal(String mealKey, DateTime date) {
    TextEditingController searchCtrl = TextEditingController();
    File? tempImage;

    String mealName = "";
    if (mealKey == 'breakfast') mealName = "아침";
    else if (mealKey == 'lunch') mealName = "점심";
    else mealName = "저녁";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: SizedBox(
                height: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더: "5일 점심" 형태
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${date.day}일 $mealName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // 검색창 + 사진 버튼
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setModalState(() {
                                tempImage = File(pickedFile.path);
                              });
                            }
                          },
                          child: Container(
                            width: 50, height: 50,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              image: tempImage != null 
                                  ? DecorationImage(image: FileImage(tempImage!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: tempImage == null 
                                ? const Icon(Icons.camera_alt, color: Colors.grey) 
                                : null,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            decoration: InputDecoration(
                              hintText: "음식 검색 (예: 김밥)",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true, fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0)
                            ),
                            onChanged: (val) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 카테고리 대신 즐겨찾기(Favorites) 표시
                    if (searchCtrl.text.isEmpty) ...[
                      const Text("자주 먹는 음식", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: _favorites.map((food) => ActionChip(
                          label: Text(food),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          onPressed: () {
                            searchCtrl.text = food;
                            setModalState(() {});
                          },
                        )).toList(),
                      ),
                    ],

                    // 검색 결과 표시 (이미지 경로 전달)
                    Expanded(
                      child: searchCtrl.text.isNotEmpty 
                        ? _buildSearchResults(searchCtrl.text, mealKey, date, tempImage?.path) 
                        : const SizedBox(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(String query, String mealKey, DateTime date, String? imagePath) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('foods')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .limit(20).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        
        if (docs.isEmpty) {
           return const Center(child: Text("검색 결과가 없습니다."));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${data['kcal']} kcal"),
              trailing: const Icon(Icons.add_circle, color: Colors.blue),
              onTap: () {
                _addFoodLog(mealKey, data, date, imagePath); 
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _addFoodLog(String mealType, Map<String, dynamic> foodData, DateTime date, String? imagePath) async {
    await FirebaseFirestore.instance.collection('diet_logs').add({
      'date': _getDateString(date),
      'mealType': mealType,
      'foodName': foodData['name'],
      'imagePath': imagePath ?? "",
      'kcal': foodData['kcal'] ?? 0,
      'carbo': foodData['carbo'] ?? 0,
      'protein': foodData['protein'] ?? 0,
      'fat': foodData['fat'] ?? 0,
      'vit_c': foodData['vit_c'] ?? 0,
      'calcium': foodData['calcium'] ?? 0,
      'sodium': foodData['sodium'] ?? 0,
      'trans_fat': foodData['trans_fat'] ?? 0,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _deleteLog(String? docId) async {
    if (docId != null) {
      await FirebaseFirestore.instance.collection('diet_logs').doc(docId).delete();
    }
  }
}