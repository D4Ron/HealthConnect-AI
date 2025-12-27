import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/questionnaire_data.dart';
import '../../widgets/common/custom_button.dart';
import 'questionnaire_result_screen.dart';

class DailyQuestionnaireScreen extends StatefulWidget {
  const DailyQuestionnaireScreen({super.key});

  @override
  State<DailyQuestionnaireScreen> createState() =>
      _DailyQuestionnaireScreenState();
}

class _DailyQuestionnaireScreenState extends State<DailyQuestionnaireScreen> {
  final Map<String, int> _responses = {};
  List<QuestionModel> _allQuestions = [];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final conditions = healthProvider.medicalProfile?.conditions ?? ['general'];

    final questionsByCondition =
    QuestionnaireData.getQuestionsByCondition(conditions);

    // Flatten all questions into one list
    _allQuestions = [];
    questionsByCondition.forEach((key, questions) {
      _allQuestions.addAll(questions);
    });
  }

  void _handleAnswer(int answerIndex) {
    setState(() {
      _responses[_allQuestions[_currentQuestionIndex].id] = answerIndex;

      if (_currentQuestionIndex < _allQuestions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitQuestionnaire();
      }
    });
  }

  void _handlePrevious() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuestionnaire() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    // Simple risk calculation based on responses
    int totalScore = 0;
    _responses.forEach((key, value) {
      totalScore += value;
    });

    final avgScore = totalScore / _responses.length;
    String status;

    if (avgScore <= 1.5) {
      status = 'critical';
    } else if (avgScore <= 2.5) {
      status = 'urgent';
    } else if (avgScore <= 3.5) {
      status = 'moderate';
    } else {
      status = 'stable';
    }

    final success = await healthProvider.submitHealthCheckIn(
      userId: authProvider.currentUser!.id,
      questionnaireResponses: _responses.map((k, v) => MapEntry(k, v)),
      riskScore: (avgScore * 25).toInt(),
      status: status,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuestionnaireResultScreen(status: status),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _allQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _allQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan Quotidien'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Counter
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_allQuestions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Question Text
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Answer Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final isSelected =
                            _responses[currentQuestion.id] == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _handleAnswer(index),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Navigation Buttons
                  if (_currentQuestionIndex > 0)
                    TextButton.icon(
                      onPressed: _handlePrevious,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Question précédente'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}