import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/questionnaire_controller.dart';
import '../../models/questionnaire.dart';
import '../../widgets/question_widgets.dart';

/// Full-screen questionnaire for orthostatic hypotension assessment
/// Follows SRP - Only responsible for displaying and managing questionnaire UI
class QuestionnaireScreen extends StatefulWidget {
  final String templateId;

  const QuestionnaireScreen({
    super.key,
    required this.templateId,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestionnaire();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestionnaire() async {
    final controller = context.read<QuestionnaireController>();
    await controller.startQuestionnaire(widget.templateId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Questionnaire'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: _handleBack,
        ),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: Text(
              'Save Draft',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<QuestionnaireController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return _buildErrorState(controller.error!);
          }

          if (controller.currentTemplate == null) {
            return _buildErrorState('Questionnaire not found');
          }

          final template = controller.currentTemplate!;
          final questions = template.questions;

          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(questions.length),
              
              // Questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Prevent swipe navigation
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionPage(
                      questions[index],
                      controller,
                    );
                  },
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(controller, questions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    final progress = totalQuestions > 0 ? (_currentPage + 1) / totalQuestions : 0.0;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentPage + 1} of $totalQuestions',
                    style: AppTextStyles.bodyLarge,
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildQuestionPage(Question question, QuestionnaireController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Required indicator
          if (question.required)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'REQUIRED',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Question widget based on type
          _buildQuestionWidget(question, controller),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Question question, QuestionnaireController controller) {
    final currentValue = controller.getAnswer(question.id);
    
    switch (question.type) {
      case QuestionType.scale:
        return ScaleQuestionWidget(
          question: question,
          currentValue: currentValue as int?,
          onChanged: (value) {
            controller.answerQuestion(questionId: question.id, value: value);
          },
        );
        
      case QuestionType.ratingWithLabels:
        return RatingWithLabelsWidget(
          question: question,
          currentValue: currentValue as int?,
          onChanged: (value) {
            controller.answerQuestion(questionId: question.id, value: value);
          },
        );
        
      case QuestionType.dateTime:
        // Determine if this is a time-only question
        final isTimeOnly = question.text.toLowerCase().contains('time') &&
            !question.text.toLowerCase().contains('date');
        
        return DateTimeQuestionWidget(
          question: question,
          currentValue: currentValue as DateTime?,
          onChanged: (value) {
            controller.answerQuestion(questionId: question.id, value: value);
          },
          timeOnly: isTimeOnly,
        );
        
      case QuestionType.textInput:
        return TextQuestionWidget(
          question: question,
          currentValue: currentValue as String?,
          onChanged: (value) {
            controller.answerQuestion(questionId: question.id, value: value);
          },
        );
        
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestionWidget(
          question: question,
          currentValue: currentValue as String?,
          onChanged: (value) {
            controller.answerQuestion(questionId: question.id, value: value);
          },
        );
        
      case QuestionType.table:
        // For BP measurement table, show placeholder for now
        // This can be expanded based on specific needs
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 16),
            MultipleChoiceQuestionWidget(
              question: question,
              currentValue: currentValue as String?,
              onChanged: (value) {
                controller.answerQuestion(questionId: question.id, value: value);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'BP measurements will be taken automatically from your connected device',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildNavigationButtons(
    QuestionnaireController controller,
    List<Question> questions,
  ) {
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == questions.length - 1;
    final currentQuestion = questions[_currentPage];
    final hasAnswer = controller.hasAnswer(currentQuestion.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirstPage)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Back'),
              ),
            ),
          
          if (!isFirstPage) const SizedBox(width: 16),
          
          // Next/Submit button
          Expanded(
            flex: isFirstPage ? 1 : 1,
            child: ElevatedButton(
              onPressed: hasAnswer || !currentQuestion.required
                  ? () => isLastPage ? _submitQuestionnaire(controller) : _nextPage()
                  : null,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLastPage ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitQuestionnaire(QuestionnaireController controller) async {
    // Check if all required questions are answered
    if (!controller.areRequiredQuestionsAnswered()) {
      final unanswered = controller.getUnansweredRequiredQuestions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all required questions. ${unanswered.length} remaining.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await controller.submitQuestionnaire();

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Questionnaire submitted successfully!',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.normal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate back
      Navigator.of(context).pop(true);
    } else if (mounted) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.error ?? 'Failed to submit questionnaire',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveDraft() async {
    final controller = context.read<QuestionnaireController>();
    await controller.saveProgress();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Progress saved',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleBack() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Questionnaire?'),
        content: const Text(
          'Your progress will be saved as a draft. You can continue later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveDraft();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close questionnaire
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

