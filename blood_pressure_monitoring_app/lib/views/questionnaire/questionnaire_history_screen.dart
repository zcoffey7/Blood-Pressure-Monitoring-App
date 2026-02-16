import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/questionnaire_controller.dart';
import '../../models/questionnaire_response.dart';
import 'questionnaire_screen.dart';

class QuestionnaireHistoryScreen extends StatefulWidget {
  const QuestionnaireHistoryScreen({super.key});

  @override
  State<QuestionnaireHistoryScreen> createState() =>
      _QuestionnaireHistoryScreenState();
}

class _QuestionnaireHistoryScreenState
    extends State<QuestionnaireHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    final controller = context.read<QuestionnaireController>();
    await controller.loadResponseHistory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Health Check-Ins')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewQuestionnaire(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, size: 28, color: Colors.white),
        label: Text('New Check-In',
            style: AppTextStyles.bodyLarge
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<QuestionnaireController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return _buildErrorState(controller.error!);
          }
          if (controller.responseHistory.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            color: AppColors.primary,
            child: Column(
              children: [
                _buildStatisticsCard(context, controller),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.responseHistory.length,
                    itemBuilder: (ctx, i) =>
                        _buildResponseCard(context, controller.responseHistory[i], controller),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(
      BuildContext context, QuestionnaireController controller) {
    final stats = controller.getResponseStatistics();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Your Progress',
              style: AppTextStyles.heading3
                  .copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', '${stats['total']}', Icons.list_alt,
                  AppColors.info),
              _buildStatItem('This Week', '${stats['thisWeek']}',
                  Icons.calendar_today, AppColors.normal),
              _buildStatItem('This Month', '${stats['thisMonth']}',
                  Icons.trending_up, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary(context))),
      ],
    );
  }

  Widget _buildResponseCard(BuildContext context,
      QuestionnaireResponse response, QuestionnaireController controller) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: response.isComplete ? AppColors.normal : AppColors.warning,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _viewResponse(response),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    response.isComplete
                        ? Icons.check_circle
                        : Icons.pending_outlined,
                    color: response.isComplete
                        ? AppColors.normal
                        : AppColors.warning,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          response.isComplete ? 'Completed' : 'Draft',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: response.isComplete
                                ? AppColors.normal
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dateFormat.format(response.startedAt),
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.danger,
                    iconSize: 28,
                    onPressed: () => _confirmDelete(response, controller),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: AppColors.divider(context)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(context, Icons.access_time,
                        'Started', timeFormat.format(response.startedAt)),
                  ),
                  if (response.completedAt != null)
                    Expanded(
                      child: _buildDetailItem(context, Icons.check, 'Completed',
                          timeFormat.format(response.completedAt!)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDetailItem(context, Icons.question_answer,
                  'Questions Answered', '${response.answers.length}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary(context)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary(context))),
            Text(value,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }

  void _viewResponse(QuestionnaireResponse response) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Response Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${response.isComplete ? "Completed" : "Draft"}'),
              const SizedBox(height: 8),
              Text(
                  'Started: ${DateFormat('MMM d, yyyy - h:mm a').format(response.startedAt)}'),
              if (response.completedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                    'Completed: ${DateFormat('MMM d, yyyy - h:mm a').format(response.completedAt!)}'),
              ],
              const SizedBox(height: 16),
              Text('Answers: ${response.answers.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...response.answers.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• ${a.questionId}: ${a.value}',
                        style: AppTextStyles.bodySmall),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      QuestionnaireResponse response, QuestionnaireController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Response?'),
        content: const Text(
            'This action cannot be undone. Are you sure you want to delete this questionnaire response?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDanger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await controller.deleteResponse(response.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Response deleted'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 80, color: AppColors.textHint(context)),
            const SizedBox(height: 16),
            Text('No Responses Yet', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text('Complete a questionnaire to see your history here.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center),
          ],
        ),
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
                onPressed: _loadHistory, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Future<void> _startNewQuestionnaire(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) =>
              const QuestionnaireScreen(templateId: 'orthostatic_assessment')),
    );
    if (result == true && mounted) await _loadHistory();
  }
}
