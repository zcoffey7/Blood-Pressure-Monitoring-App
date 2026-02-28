import 'blood_pressure_reading.dart';

/// Model representing a single answer to a question
/// Follows SRP - Only responsible for storing answer data
class QuestionAnswer {
  final String questionId;
  final dynamic value; // Can be int, String, DateTime, List<String>, etc.
  final DateTime answeredAt;

  const QuestionAnswer({
    required this.questionId,
    required this.value,
    required this.answeredAt,
  });

  /// Factory constructor for JSON serialization
  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionId: json['questionId'] as String,
      value: json['value'],
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  /// Copy with method for immutability
  QuestionAnswer copyWith({
    String? questionId,
    dynamic value,
    DateTime? answeredAt,
  }) {
    return QuestionAnswer(
      questionId: questionId ?? this.questionId,
      value: value ?? this.value,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}

/// Model representing a complete questionnaire response
/// Follows SRP - Manages collection of answers
class QuestionnaireResponse {
  final String id;
  final String templateId;
  final String userId; // For future multi-user support
  final List<QuestionAnswer> answers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isComplete;

  // Optional: Link to BP readings taken during this questionnaire
  final List<BloodPressureReading>? associatedReadings;

  // Additional context
  final Map<String, dynamic>? metadata;

  const QuestionnaireResponse({
    required this.id,
    required this.templateId,
    required this.userId,
    required this.answers,
    required this.startedAt,
    this.completedAt,
    this.isComplete = false,
    this.associatedReadings,
    this.metadata,
  });

  /// Factory constructor for JSON serialization
  factory QuestionnaireResponse.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponse(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      userId: json['userId'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((a) => QuestionAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isComplete: json['isComplete'] as bool? ?? false,
      associatedReadings: (json['associatedReadings'] as List<dynamic>?)
          ?.map((r) => BloodPressureReading.fromJson(r as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'userId': userId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'isComplete': isComplete,
      if (associatedReadings != null)
        'associatedReadings': associatedReadings!
            .map((r) => r.toJson())
            .toList(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Copy with method for immutability
  QuestionnaireResponse copyWith({
    String? id,
    String? templateId,
    String? userId,
    List<QuestionAnswer>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isComplete,
    List<BloodPressureReading>? associatedReadings,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionnaireResponse(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      userId: userId ?? this.userId,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isComplete: isComplete ?? this.isComplete,
      associatedReadings: associatedReadings ?? this.associatedReadings,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get answer for a specific question
  QuestionAnswer? getAnswer(String questionId) {
    for (final answer in answers) {
      if (answer.questionId == questionId) return answer;
    }
    return null;
  }

  /// Check if a specific question has been answered
  bool hasAnswer(String questionId) {
    return answers.any((answer) => answer.questionId == questionId);
  }

  @override
  String toString() {
    return 'QuestionnaireResponse(id: $id, templateId: $templateId, isComplete: $isComplete, answers: ${answers.length})';
  }
}

/// Model for BP measurement entry (for table-based BP assessment)
/// Follows SRP - Represents a single BP measurement row
class BPMeasurementEntry {
  final String measurementType; // 'Supine 1', 'Stand 1', 'Sit 1', etc.
  final String arm; // 'left' or 'right'
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final String? comments;

  const BPMeasurementEntry({
    required this.measurementType,
    required this.arm,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.comments,
  });

  /// Factory constructor for JSON serialization
  factory BPMeasurementEntry.fromJson(Map<String, dynamic> json) {
    return BPMeasurementEntry(
      measurementType: json['measurementType'] as String,
      arm: json['arm'] as String,
      systolic: json['systolic'] as int?,
      diastolic: json['diastolic'] as int?,
      heartRate: json['heartRate'] as int?,
      comments: json['comments'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'measurementType': measurementType,
      'arm': arm,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (heartRate != null) 'heartRate': heartRate,
      if (comments != null) 'comments': comments,
    };
  }
}
