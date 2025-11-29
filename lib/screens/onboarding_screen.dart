import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import '../models/survey_question_model.dart';
import 'result_screen.dart';
import '../widgets/question_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식습관 자가진단'),
        centerTitle: true,
      ),
      body: Consumer<SurveyProvider>(
        builder: (context, surveyProvider, child) {
          // 설문이 완료되면 결과 화면으로 이동
          if (surveyProvider.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    score: surveyProvider.calculateScore(),
                    personaType: surveyProvider.determinePersonaType(),
                  ),
                ),
              );
            });
          }

          return Column(
            children: [
              // 진행률 표시
              _buildProgressIndicator(surveyProvider),
              
              // 질문 페이지뷰
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: surveyProvider.totalQuestions,
                  itemBuilder: (context, index) {
                    final question = surveyProvider.questions[index];
                    return _buildQuestionPage(question, surveyProvider);
                  },
                ),
              ),

              // 네비게이션 버튼
              _buildNavigationButtons(surveyProvider),
            ],
          );
        },
      ),
    );
  }

  /// 진행률 표시
  Widget _buildProgressIndicator(SurveyProvider provider) {
    final progress = (provider.currentPageIndex + 1) / provider.totalQuestions;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.currentPageIndex + 1} / ${provider.totalQuestions}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  /// 질문 페이지 빌드
  Widget _buildQuestionPage(
    SurveyQuestion question,
    SurveyProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            question.question,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 32),
          QuestionWidget(
            question: question,
            initialAnswer: provider.getAnswer(question.id),
            onAnswerChanged: (answer) {
              provider.setAnswer(question.id, answer);
            },
          ),
        ],
      ),
    );
  }

  /// 네비게이션 버튼
  Widget _buildNavigationButtons(SurveyProvider provider) {
    final isFirstPage = provider.currentPageIndex == 0;
    final isLastPage = provider.currentPageIndex == provider.totalQuestions - 1;
    final currentQuestion = provider.getCurrentQuestion();
    final hasAnswer = currentQuestion != null &&
        provider.getAnswer(currentQuestion.id) != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstPage)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  provider.previousPage();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('이전'),
              ),
            ),
          if (!isFirstPage) const SizedBox(width: 12),
          Expanded(
            flex: isFirstPage ? 1 : 2,
            child: ElevatedButton(
              onPressed: hasAnswer
                  ? () {
                      if (isLastPage) {
                        provider.completeSurvey();
                      } else {
                        provider.nextPage();
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  : null,
              child: Text(isLastPage ? '완료' : '다음'),
            ),
          ),
        ],
      ),
    );
  }
}
