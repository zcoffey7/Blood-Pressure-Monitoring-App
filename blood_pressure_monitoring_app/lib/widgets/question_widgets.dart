import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/questionnaire.dart';

/// Widget for displaying and answering a scale question (0-10)
/// Follows SRP - Only handles scale question UI
class ScaleQuestionWidget extends StatelessWidget {
  final Question question;
  final int? currentValue;
  final Function(int) onChanged;

  const ScaleQuestionWidget({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 24),

        // Scale buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            (question.maxValue! - question.minValue! + 1),
            (index) {
              final value = question.minValue! + index;
              final isSelected = currentValue == value;

              return _ScaleButton(
                value: value,
                isSelected: isSelected,
                onTap: () => onChanged(value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScaleButton extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScaleButton({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$value',
            style: AppTextStyles.heading2.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for rating questions with text labels (1-7 fatigue scale)
/// Follows SRP - Only handles rating with labels UI
class RatingWithLabelsWidget extends StatelessWidget {
  final Question question;
  final int? currentValue;
  final Function(int) onChanged;

  const RatingWithLabelsWidget({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 24),

        // Rating options with labels
        ...List.generate(question.ratingLabels!.length, (index) {
          final value = question.minValue! + index;
          final label = question.ratingLabels![value] ?? '';
          final isSelected = currentValue == value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RatingOption(
              value: value,
              label: label,
              isSelected: isSelected,
              onTap: () => onChanged(value),
            ),
          );
        }),
      ],
    );
  }
}

class _RatingOption extends StatelessWidget {
  final int value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatingOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: AppTextStyles.heading3.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for date/time picker questions
/// Follows SRP - Only handles date/time input UI
class DateTimeQuestionWidget extends StatelessWidget {
  final Question question;
  final DateTime? currentValue;
  final Function(DateTime) onChanged;
  final bool timeOnly;

  const DateTimeQuestionWidget({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
    this.timeOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 16),

        InkWell(
          onTap: () => _selectDateTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: currentValue != null
                    ? AppColors.primary
                    : AppColors.divider,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  timeOnly ? Icons.access_time : Icons.calendar_today,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    currentValue != null
                        ? _formatDateTime(currentValue!)
                        : 'Tap to select ${timeOnly ? "time" : "date & time"}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: currentValue != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (timeOnly) {
      final time = await showTimePicker(
        context: context,
        initialTime: currentValue != null
            ? TimeOfDay.fromDateTime(currentValue!)
            : TimeOfDay.now(),
      );

      if (time != null) {
        final now = DateTime.now();
        final selected = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        onChanged(selected);
      }
    } else {
      final date = await showDatePicker(
        context: context,
        initialDate: currentValue ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (date != null && context.mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: currentValue != null
              ? TimeOfDay.fromDateTime(currentValue!)
              : TimeOfDay.now(),
        );

        if (time != null) {
          final selected = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          onChanged(selected);
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    if (timeOnly) {
      return DateFormat('h:mm a').format(dateTime);
    }
    return DateFormat('MMM d, yyyy - h:mm a').format(dateTime);
  }
}

/// Widget for text input questions
/// Follows SRP - Only handles text input UI
class TextQuestionWidget extends StatefulWidget {
  final Question question;
  final String? currentValue;
  final Function(String) onChanged;

  const TextQuestionWidget({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<TextQuestionWidget> createState() => _TextQuestionWidgetState();
}

class _TextQuestionWidgetState extends State<TextQuestionWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void didUpdateWidget(TextQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if currentValue changed externally
    if (oldWidget.currentValue != widget.currentValue) {
      _controller.text = widget.currentValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.text, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 16),

        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: AppTextStyles.bodyLarge,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: widget.question.placeholder ?? 'Enter your response...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textHint,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

/// Widget for multiple choice questions
/// Follows SRP - Only handles multiple choice UI
class MultipleChoiceQuestionWidget extends StatelessWidget {
  final Question question;
  final String? currentValue;
  final Function(String) onChanged;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 24),

        ...question.options!.map((option) {
          final isSelected = currentValue == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
