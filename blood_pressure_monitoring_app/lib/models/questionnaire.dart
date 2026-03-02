/// Model representing different types of questions
/// Follows SRP - Each question type has specific properties
enum QuestionType {
  scale, // 0-10 numeric scale
  ratingWithLabels, // 1-7 or other scale with text descriptions
  textInput, // Free text input
  dateTime, // Date and time picker
  multipleChoice, // Single selection from options
  table, // For BP measurement table
  bloodPressureInput, // Systolic + diastolic number entry
}

/// Model representing a single question in the questionnaire
/// Follows SRP - Only responsible for question structure
class Question {
  final String id;
  final String text;
  final QuestionType type;
  final bool required;
  final int? minValue;
  final int? maxValue;
  final String? minLabel;
  final String? maxLabel;
  final List<String>? options;
  final Map<int, String>? ratingLabels; // For rating scales with descriptions
  final String? placeholder;

  const Question({
    required this.id,
    required this.text,
    required this.type,
    this.required = true,
    this.minValue,
    this.maxValue,
    this.minLabel,
    this.maxLabel,
    this.options,
    this.ratingLabels,
    this.placeholder,
  });

  /// Factory constructor for JSON serialization
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.values.byName(json['type'] as String),
      required: json['required'] as bool? ?? true,
      minValue: json['minValue'] as int?,
      maxValue: json['maxValue'] as int?,
      minLabel: json['minLabel'] as String?,
      maxLabel: json['maxLabel'] as String?,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      ratingLabels: (json['ratingLabels'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), value as String),
      ),
      placeholder: json['placeholder'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'required': required,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (minLabel != null) 'minLabel': minLabel,
      if (maxLabel != null) 'maxLabel': maxLabel,
      if (options != null) 'options': options,
      if (ratingLabels != null)
        'ratingLabels': ratingLabels!.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      if (placeholder != null) 'placeholder': placeholder,
    };
  }
}

/// Model representing a complete questionnaire template
/// Follows SRP - Manages collection of questions
class QuestionnaireTemplate {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final DateTime? createdAt;

  const QuestionnaireTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.createdAt,
  });

  /// Factory constructor for JSON serialization
  factory QuestionnaireTemplate.fromJson(Map<String, dynamic> json) {
    return QuestionnaireTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
