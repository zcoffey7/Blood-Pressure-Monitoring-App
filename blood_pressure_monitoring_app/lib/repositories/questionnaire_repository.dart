import '../models/questionnaire.dart';
import '../models/questionnaire_response.dart';

/// Abstract repository interface for questionnaire data
/// Follows OCP - Open for extension (can implement Firebase, API, etc.)
/// Follows DIP - Depends on abstraction, not concrete implementation
abstract class QuestionnaireRepository {
  /// Get a questionnaire template by ID
  Future<QuestionnaireTemplate> getTemplate(String templateId);

  /// Get all available questionnaire templates
  Future<List<QuestionnaireTemplate>> getAllTemplates();

  /// Save a questionnaire response
  Future<void> saveResponse(QuestionnaireResponse response);

  /// Get a specific response by ID
  Future<QuestionnaireResponse?> getResponse(String responseId);

  /// Get all responses for a specific user
  Future<List<QuestionnaireResponse>> getResponsesByUser(String userId);

  /// Get responses within a date range
  Future<List<QuestionnaireResponse>> getResponsesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  });

  /// Update an existing response
  Future<void> updateResponse(QuestionnaireResponse response);

  /// Delete a response
  Future<void> deleteResponse(String responseId);

  /// Get the most recent response for a template
  Future<QuestionnaireResponse?> getLatestResponse({
    required String templateId,
    String? userId,
  });
}

/// Mock implementation of QuestionnaireRepository
/// Follows SRP - Only responsible for mock data operations
/// Can be easily replaced with Firebase/API implementation
class MockQuestionnaireRepository implements QuestionnaireRepository {
  // In-memory storage for mock data
  final Map<String, QuestionnaireTemplate> _templates = {};
  final Map<String, QuestionnaireResponse> _responses = {};

  MockQuestionnaireRepository() {
    _initializeMockTemplates();
  }

  /// Initialize with the three health tracker templates
  void _initializeMockTemplates() {
    // 1. Symptom Tracker — all questions optional
    final symptomTracker = QuestionnaireTemplate(
      id: 'symptom_tracker',
      title: 'Symptom Tracker',
      description: 'Track your daily symptoms quickly',
      createdAt: DateTime.now(),
      questions: [
        const Question(
          id: 'assessment_date',
          text: "Today's Date and Time",
          type: QuestionType.dateTime,
          required: false,
        ),
        const Question(
          id: 'postural_symptoms',
          text:
              'Postural symptoms: Rate how severe the following symptoms were when upright (standing/sitting): dizziness, lightheadedness, feeling faint, vision problems, weakness, fatigue, trouble concentrating, neck/shoulder pain, nausea (0 = None, 10 = Worst possible).',
          type: QuestionType.scale,
          required: false,
          minValue: 0,
          maxValue: 10,
        ),
        const Question(
          id: 'fatigue_level',
          text: 'Current fatigue level: Rate your current level of fatigue.',
          type: QuestionType.ratingWithLabels,
          required: false,
          minValue: 1,
          maxValue: 7,
          ratingLabels: {
            1: 'Fully Alert, wide awake',
            2: 'Very lively, responsive, but not at peak',
            3: 'Okay, somewhat fresh',
            4: 'A little tired, less than fresh',
            5: 'Moderately tired, let down',
            6: 'Extremely tired, very difficult to concentrate',
            7: 'Completely exhausted, unable to function effectively',
          },
        ),
        const Question(
          id: 'last_meal_day',
          text: 'When was your last meal?',
          type: QuestionType.multipleChoice,
          required: false,
          options: ['Today', 'Yesterday'],
        ),
        const Question(
          id: 'other_symptoms',
          text: 'Other symptoms',
          type: QuestionType.textInput,
          required: false,
          placeholder: 'Describe any other symptoms...',
        ),
      ],
    );

    // 2. Sleep Tracker — all questions optional
    final sleepTracker = QuestionnaireTemplate(
      id: 'sleep_tracker',
      title: 'Sleep Tracker',
      description: 'Track your sleep quality and patterns',
      createdAt: DateTime.now(),
      questions: [
        const Question(
          id: 'assessment_date',
          text: "Today's Date",
          type: QuestionType.dateTime,
          required: false,
        ),
        const Question(
          id: 'last_meal_day',
          text: 'When was your last meal?',
          type: QuestionType.multipleChoice,
          required: false,
          options: ['Today', 'Yesterday'],
        ),
        const Question(
          id: 'last_meal_time',
          text: 'What time was your last meal?',
          type: QuestionType.dateTime,
          required: false,
        ),
        const Question(
          id: 'bedtime',
          text: "Yesterday's Bed Time",
          type: QuestionType.dateTime,
          required: false,
        ),
        const Question(
          id: 'wakeup_time',
          text: "Today's Wake-up Time",
          type: QuestionType.dateTime,
          required: false,
        ),
        const Question(
          id: 'sleep_quality',
          text:
              'Sleep quality: Rate the quality of your sleep last night (0 = Best possible sleep, 10 = Worst possible sleep).',
          type: QuestionType.scale,
          required: false,
          minValue: 0,
          maxValue: 10,
        ),
        const Question(
          id: 'fatigue_score',
          text:
              'Fatigue within 1 hour of waking: Rate your fatigue level.',
          type: QuestionType.ratingWithLabels,
          required: false,
          minValue: 1,
          maxValue: 7,
          ratingLabels: {
            1: 'Fully Alert, wide awake',
            2: 'Very lively, responsive, but not at peak',
            3: 'Okay, somewhat fresh',
            4: 'A little tired, less than fresh',
            5: 'Moderately tired, let down',
            6: 'Extremely tired, very difficult to concentrate',
            7: 'Completely exhausted, unable to function effectively',
          },
        ),
        const Question(
          id: 'notes',
          text: 'Notes',
          type: QuestionType.textInput,
          required: false,
          placeholder: 'Any additional notes...',
        ),
      ],
    );

    // 3. Blood Pressure Tracker — all questions optional
    final bpTracker = QuestionnaireTemplate(
      id: 'bp_tracker',
      title: 'Blood Pressure Tracker',
      description: 'Record your blood pressure measurements',
      createdAt: DateTime.now(),
      questions: [
        const Question(
          id: 'assessment_date',
          text: 'Date and Time',
          type: QuestionType.dateTime,
          required: false,
        ),
        const Question(
          id: 'posture',
          text: 'Posture',
          type: QuestionType.multipleChoice,
          required: false,
          options: ['Lying down', 'Sitting', 'Standing'],
        ),
        const Question(
          id: 'bp_readings',
          text: 'What were your blood pressure readings?',
          type: QuestionType.bloodPressureInput,
          required: false,
        ),
        const Question(
          id: 'notes',
          text: 'Notes',
          type: QuestionType.textInput,
          required: false,
        ),
      ],
    );

    _templates[symptomTracker.id] = symptomTracker;
    _templates[sleepTracker.id] = sleepTracker;
    _templates[bpTracker.id] = bpTracker;
  }

  @override
  Future<QuestionnaireTemplate> getTemplate(String templateId) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate network delay

    final template = _templates[templateId];
    if (template == null) {
      throw Exception('Template not found: $templateId');
    }
    return template;
  }

  @override
  Future<List<QuestionnaireTemplate>> getAllTemplates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _templates.values.toList();
  }

  @override
  Future<void> saveResponse(QuestionnaireResponse response) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _responses[response.id] = response;
  }

  @override
  Future<QuestionnaireResponse?> getResponse(String responseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _responses[responseId];
  }

  @override
  Future<List<QuestionnaireResponse>> getResponsesByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _responses.values
        .where((response) => response.userId == userId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt)); // Most recent first
  }

  @override
  Future<List<QuestionnaireResponse>> getResponsesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _responses.values.where((response) {
      final inDateRange =
          response.startedAt.isAfter(startDate) &&
          response.startedAt.isBefore(endDate);
      final matchesUser = userId == null || response.userId == userId;
      return inDateRange && matchesUser;
    }).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<void> updateResponse(QuestionnaireResponse response) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_responses.containsKey(response.id)) {
      throw Exception('Response not found: ${response.id}');
    }
    _responses[response.id] = response;
  }

  @override
  Future<void> deleteResponse(String responseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _responses.remove(responseId);
  }

  @override
  Future<QuestionnaireResponse?> getLatestResponse({
    required String templateId,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final matchingResponses = _responses.values.where((response) {
      final matchesTemplate = response.templateId == templateId;
      final matchesUser = userId == null || response.userId == userId;
      return matchesTemplate && matchesUser;
    }).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return matchingResponses.isNotEmpty ? matchingResponses.first : null;
  }
}
