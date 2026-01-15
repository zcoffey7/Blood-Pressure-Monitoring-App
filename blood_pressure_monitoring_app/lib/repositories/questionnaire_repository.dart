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

  /// Initialize with the orthostatic hypotension questionnaire template
  void _initializeMockTemplates() {
    final orthostaticTemplate = QuestionnaireTemplate(
      id: 'orthostatic_assessment',
      title: 'Orthostatic Blood Pressure Assessment',
      description: 'Complete assessment for monitoring orthostatic hypotension',
      createdAt: DateTime.now(),
      questions: [
        // Today's date (auto-filled)
        const Question(
          id: 'assessment_date',
          text: "Today's Date",
          type: QuestionType.dateTime,
          required: true,
        ),

        // Current time (auto-filled)
        const Question(
          id: 'current_time',
          text: 'Current Time',
          type: QuestionType.dateTime,
          required: true,
        ),

        // Yesterday's last meal time
        const Question(
          id: 'last_meal_time',
          text: "Yesterday's Last Meal Time",
          type: QuestionType.dateTime,
          required: true,
        ),

        // Yesterday's bedtime
        const Question(
          id: 'bedtime',
          text: "Yesterday's Bed Time",
          type: QuestionType.dateTime,
          required: true,
        ),

        // Today's wake-up time
        const Question(
          id: 'wakeup_time',
          text: "Today's Wake-up Time",
          type: QuestionType.dateTime,
          required: true,
        ),

        // Sleep quality (0-10 scale)
        const Question(
          id: 'sleep_quality',
          text:
              'Sleep quality: Assign a number on the scale that best rates the quality of your sleep last night.',
          type: QuestionType.scale,
          required: true,
          minValue: 0,
          maxValue: 10,
          minLabel: 'Best possible sleep',
          maxLabel: 'Worst possible sleep',
        ),

        // Fatigue level before test (1-7 rating with labels)
        Question(
          id: 'fatigue_before',
          text:
              'Fatigue level before the test: Assign a number on the scale that best rates your current level of fatigue.',
          type: QuestionType.ratingWithLabels,
          required: true,
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

        // Blood pressure measurement table
        const Question(
          id: 'bp_measurements',
          text: 'Blood pressure assessment: Which arm?',
          type: QuestionType.table,
          required: true,
          options: ['Left', 'Right'],
        ),

        // Fatigue level after test (1-7 rating with labels)
        Question(
          id: 'fatigue_after',
          text:
              'Fatigue level after the test: Assign a number on the scale that best rates your level of fatigue after finishing the blood pressure assessment.',
          type: QuestionType.ratingWithLabels,
          required: true,
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

        // Postural symptoms (0-10 severity scale)
        const Question(
          id: 'postural_symptoms',
          text:
              'Postural symptoms: Assign a number on the scale that best rates how severe the following symptoms were that occurred when upright (standing and/or sitting): Dizziness/lightheadedness, feeling faint or like you might blackout, vision problems (blurry, tunnel vision, diminished vision, seeing spots, etc.), weakness, fatigue, trouble concentrating, pain or discomfort in shoulders/back of neck, nausea.',
          type: QuestionType.scale,
          required: true,
          minValue: 0,
          maxValue: 10,
          minLabel: 'None',
          maxLabel: 'Worst possible',
        ),

        // Overall number (0-10 scale)
        const Question(
          id: 'overall_rating',
          text: 'Give one overall number:',
          type: QuestionType.scale,
          required: true,
          minValue: 0,
          maxValue: 10,
          minLabel: 'None',
          maxLabel: 'Worst possible',
        ),
      ],
    );

    _templates[orthostaticTemplate.id] = orthostaticTemplate;
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
