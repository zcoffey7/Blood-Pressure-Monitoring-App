import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/questionnaire_controller.dart';
import '../../models/questionnaire_response.dart';
import 'questionnaire_screen.dart';

/// Screen displaying history of completed questionnaires
/// Follows SRP - Only responsible for displaying questionnaire history
class QuestionnaireHistoryScreen extends StatefulWidget {
  const QuestionnaireHistoryScreen({super.key});

  @override
  State<QuestionnaireHistoryScreen> createState() => _QuestionnaireHistoryScreenState();
}

class _QuestionnaireHistoryScreenState extends State<QuestionnaireHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final controller = context.read<QuestionnaireController>();
    await controller.loadResponseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Check-Ins'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewQuestionnaire(context),
        backgroundColor: AppColors.normal,
        icon: const Icon(Icons.add, size: 28),
        label: Text(
          'New Check-In',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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

          if (controller.responseHistory.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            color: AppColors.primary,
            child: Column(
              children: [
                // Statistics Card
                _buildStatisticsCard(controller),
                
                // Response List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.responseHistory.length,
                    itemBuilder: (context, index) {
                      final response = controller.responseHistory[index];
                      return _buildResponseCard(response, controller);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCard(QuestionnaireController controller) {
    final stats = controller.getResponseStatistics();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Your Progress', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Total',
                value: '${stats['total']}',
                icon: Icons.list_alt,
                color: AppColors.info,
              ),
              _buildStatItem(
                label: 'This Week',
                value: '${stats['thisWeek']}',
                icon: Icons.calendar_today,
                color: AppColors.normal,
              ),
              _buildStatItem(
                label: 'This Month',
                value: '${stats['thisMonth']}',
                icon: Icons.trending_up,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResponseCard(
    QuestionnaireResponse response,
    QuestionnaireController controller,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: response.isComplete ? AppColors.normal : AppColors.warning,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _viewResponse(response),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
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
                        Text(
                          dateFormat.format(response.startedAt),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
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
              const Divider(),
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.access_time,
                      label: 'Started',
                      value: timeFormat.format(response.startedAt),
                    ),
                  ),
                  if (response.completedAt != null)
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.check,
                        label: 'Completed',
                        value: timeFormat.format(response.completedAt!),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.question_answer,
                      label: 'Questions Answered',
                      value: '${response.answers.length}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _viewResponse(QuestionnaireResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Response Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${response.isComplete ? "Completed" : "Draft"}'),
              const SizedBox(height: 8),
              Text(
                'Started: ${DateFormat('MMM d, yyyy - h:mm a').format(response.startedAt)}',
              ),
              if (response.completedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Completed: ${DateFormat('MMM d, yyyy - h:mm a').format(response.completedAt!)}',
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Answers: ${response.answers.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...response.answers.map((answer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• ${answer.questionId}: ${answer.value}',
                    style: AppTextStyles.bodySmall,
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    QuestionnaireResponse response,
    QuestionnaireController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Response?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this questionnaire response?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await controller.deleteResponse(response.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Response deleted',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No Responses Yet',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a questionnaire to see your history here.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
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
              onPressed: _loadHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Start new questionnaire
  Future<void> _startNewQuestionnaire(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuestionnaireScreen(
          templateId: 'orthostatic_assessment',
        ),
      ),
    );

    // If questionnaire was completed, refresh history
    if (result == true && mounted) {
      await _loadHistory();
    }
  }
}

