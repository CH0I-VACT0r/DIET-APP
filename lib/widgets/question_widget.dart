import 'package:flutter/material.dart';
import '../models/survey_question_model.dart';

class QuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final dynamic initialAnswer;
  final ValueChanged<dynamic> onAnswerChanged;

  const QuestionWidget({
    super.key,
    required this.question,
    this.initialAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  dynamic _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _selectedAnswer = widget.initialAnswer;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice();
      case QuestionType.multipleChoice:
        return _buildMultipleChoice();
      case QuestionType.boolean:
        return _buildBoolean();
      case QuestionType.number:
        return _buildNumber();
      case QuestionType.text:
        return _buildText();
    }
  }

  /// 단일 선택
  Widget _buildSingleChoice() {
    return Column(
      children: widget.question.options!.map((option) {
        final isSelected = _selectedAnswer == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedAnswer = option;
              });
              widget.onAnswerChanged(_selectedAnswer);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 다중 선택
  Widget _buildMultipleChoice() {
    List<String> selectedList = _selectedAnswer is List
        ? List<String>.from(_selectedAnswer)
        : [];

    return Column(
      children: widget.question.options!.map((option) {
        final isSelected = selectedList.contains(option);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedList.remove(option);
                } else {
                  selectedList.add(option);
                }
                _selectedAnswer = selectedList;
              });
              widget.onAnswerChanged(_selectedAnswer);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 예/아니오
  Widget _buildBoolean() {
    return Row(
      children: [
        Expanded(
          child: _buildBooleanOption('예', true),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBooleanOption('아니오', false),
        ),
      ],
    );
  }

  Widget _buildBooleanOption(String label, bool value) {
    final isSelected = _selectedAnswer == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAnswer = value;
        });
        widget.onAnswerChanged(_selectedAnswer);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// 숫자 입력
  Widget _buildNumber() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '숫자를 입력해주세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        final number = int.tryParse(value);
        if (number != null) {
          _selectedAnswer = number;
          widget.onAnswerChanged(_selectedAnswer);
        }
      },
    );
  }

  /// 텍스트 입력
  Widget _buildText() {
    return TextField(
      decoration: InputDecoration(
        hintText: '답변을 입력해주세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        _selectedAnswer = value;
        widget.onAnswerChanged(_selectedAnswer);
      },
    );
  }
}

