import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/questionnaire_controller.dart';
import '../../models/questionnaire.dart';
import '../../widgets/question_widgets.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String templateId;

  const QuestionnaireScreen({super.key, required this.templateId});

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuestionnaire());
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
      appBar: AppBar(
        title: const Text('Health Check-In'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: _handleBack,
        ),
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
              _buildProgressIndicator(questions.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  itemCount: questions.length,
                  itemBuilder: (ctx, i) =>
                      _buildQuestionPage(questions[i], controller),
                ),
              ),
              _buildNavigationButtons(controller, questions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(int total) {
    final progress = total > 0 ? (_currentPage + 1) / total : 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.cardBackground(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentPage + 1} of $total',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: colorScheme.onSurface)),
              Text('${(progress * 100).toInt()}%',
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider(context),
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(
      Question question, QuestionnaireController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.required)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('REQUIRED',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 24),
          _buildQuestionWidget(question, controller),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(
      Question question, QuestionnaireController controller) {
    final currentValue = controller.getAnswer(question.id);

    switch (question.type) {
      case QuestionType.scale:
        return ScaleQuestionWidget(
          question: question,
          currentValue: currentValue as int?,
          onChanged: (v) =>
              controller.answerQuestion(questionId: question.id, value: v),
        );
      case QuestionType.ratingWithLabels:
        return RatingWithLabelsWidget(
          question: question,
          currentValue: currentValue as int?,
          onChanged: (v) =>
              controller.answerQuestion(questionId: question.id, value: v),
        );
      case QuestionType.dateTime:
        final isTimeOnly = question.text.toLowerCase().contains('time') &&
            !question.text.toLowerCase().contains('date');
        return DateTimeQuestionWidget(
          question: question,
          currentValue: currentValue as DateTime?,
          onChanged: (v) =>
              controller.answerQuestion(questionId: question.id, value: v),
          timeOnly: isTimeOnly,
        );
      case QuestionType.textInput:
        return TextQuestionWidget(
          question: question,
          currentValue: currentValue as String?,
          onChanged: (v) =>
              controller.answerQuestion(questionId: question.id, value: v),
        );
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestionWidget(
          question: question,
          currentValue: currentValue as String?,
          onChanged: (v) =>
              controller.answerQuestion(questionId: question.id, value: v),
        );
      case QuestionType.table:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultipleChoiceQuestionWidget(
              question: question,
              currentValue: currentValue as String?,
              onChanged: (v) =>
                  controller.answerQuestion(questionId: question.id, value: v),
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
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
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
      QuestionnaireController controller, List<Question> questions) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == questions.length - 1;
    final currentQ = questions[_currentPage];
    final hasAnswer = controller.hasAnswer(currentQ.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: const Text('Back'),
              ),
            ),
          if (!isFirst) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: hasAnswer || !currentQ.required
                  ? () => isLast
                      ? _submitQuestionnaire(controller)
                      : _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut)
                  : null,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isLast ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuestionnaire(
      QuestionnaireController controller) async {
    if (!controller.areRequiredQuestionsAnswered()) {
      final unanswered = controller.getUnansweredRequiredQuestions();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Please answer all required questions. ${unanswered.length} remaining.'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await controller.submitQuestionnaire();
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Questionnaire submitted successfully!'),
        backgroundColor: AppColors.normal,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(controller.error ?? 'Failed to submit questionnaire'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _handleBack() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Check-In?'),
        content: const Text(
            'Your progress will not be saved. Are you sure you want to exit?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Continue')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
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
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text('Error', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(error,
                style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
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
