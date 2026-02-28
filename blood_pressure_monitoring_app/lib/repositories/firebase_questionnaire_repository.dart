import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/questionnaire.dart';
import '../models/questionnaire_response.dart';
import '../services/firestore_service.dart';
import 'questionnaire_repository.dart';

/// Firebase Firestore implementation of QuestionnaireRepository
/// Stores responses in: users/{userId}/surveys/{surveyId}
/// Templates are kept in-app (they are application-level data, not user data)
/// Follows OCP - Extends QuestionnaireRepository without modifying it
/// Follows SRP - Only responsible for Firestore questionnaire data operations
class FirebaseQuestionnaireRepository implements QuestionnaireRepository {
  final FirestoreService _firestoreService;

  // Templates are application-level data, stored in memory
  final Map<String, QuestionnaireTemplate> _templates = {};

  FirebaseQuestionnaireRepository(this._firestoreService) {
    _initializeTemplates();
  }

  /// Reference to the user's surveys collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreService.surveysCollection;

  /// Initialize questionnaire templates (app-level data, not stored in Firestore)
  void _initializeTemplates() {
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
        Question(
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
          id: 'other_symptoms',
          text: 'Other symptoms',
          type: QuestionType.textInput,
          required: false,
          placeholder: 'Describe any other symptoms...',
        ),
        const Question(
          id: 'last_meal_time',
          text: 'Last Meal Time',
          type: QuestionType.dateTime,
          required: false,
        ),
      ],
    );

    // 2. Sleep Tracker — most questions required
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
          required: true,
        ),
        const Question(
          id: 'last_meal_time',
          text: "Yesterday's Last Meal Time",
          type: QuestionType.dateTime,
          required: true,
        ),
        const Question(
          id: 'bedtime',
          text: "Yesterday's Bed Time",
          type: QuestionType.dateTime,
          required: true,
        ),
        const Question(
          id: 'wakeup_time',
          text: "Today's Wake-up Time",
          type: QuestionType.dateTime,
          required: true,
        ),
        const Question(
          id: 'sleep_quality',
          text:
              'Sleep quality: Rate the quality of your sleep last night (0 = Best possible sleep, 10 = Worst possible sleep).',
          type: QuestionType.scale,
          required: true,
          minValue: 0,
          maxValue: 10,
        ),
        Question(
          id: 'fatigue_score',
          text:
              'Fatigue within 1 hour of waking: Rate your fatigue level.',
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
        const Question(
          id: 'notes',
          text: 'Notes',
          type: QuestionType.textInput,
          required: false,
          placeholder: 'Any additional notes...',
        ),
      ],
    );

    // 3. Blood Pressure Tracker
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
          required: true,
        ),
        const Question(
          id: 'arm_used',
          text: 'Which arm?',
          type: QuestionType.multipleChoice,
          required: true,
          options: ['Left', 'Right'],
        ),
        const Question(
          id: 'posture',
          text: 'Posture',
          type: QuestionType.multipleChoice,
          required: true,
          options: ['Lying down', 'Sitting', 'Standing'],
        ),
        const Question(
          id: 'bp_measurements',
          text: 'Blood pressure measurements',
          type: QuestionType.table,
          required: true,
          options: ['Left', 'Right'],
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
    final template = _templates[templateId];
    if (template == null) {
      throw Exception('Template not found: $templateId');
    }
    return template;
  }

  @override
  Future<List<QuestionnaireTemplate>> getAllTemplates() async {
    return _templates.values.toList();
  }

  @override
  Future<void> saveResponse(QuestionnaireResponse response) async {
    try {
      await _collection.doc(response.id).set(_toFirestore(response));
    } catch (e) {
      throw Exception('Failed to save survey response: $e');
    }
  }

  @override
  Future<QuestionnaireResponse?> getResponse(String responseId) async {
    try {
      final doc = await _collection.doc(responseId).get();
      if (!doc.exists) return null;
      return _fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get survey response: $e');
    }
  }

  @override
  Future<List<QuestionnaireResponse>> getResponsesByUser(
    String userId,
  ) async {
    try {
      // All documents in the user's surveys collection belong to them
      final snapshot = await _collection
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs.map(_fromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to get survey responses: $e');
    }
  }

  @override
  Future<List<QuestionnaireResponse>> getResponsesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      final snapshot = await _collection
          .orderBy('startedAt', descending: true)
          .where(
            'startedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            'startedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .get();

      return snapshot.docs.map(_fromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to get survey responses by date range: $e');
    }
  }

  @override
  Future<void> updateResponse(QuestionnaireResponse response) async {
    try {
      final doc = await _collection.doc(response.id).get();
      if (!doc.exists) {
        throw Exception('Response not found: ${response.id}');
      }
      await _collection.doc(response.id).update(_toFirestore(response));
    } catch (e) {
      throw Exception('Failed to update survey response: $e');
    }
  }

  @override
  Future<void> deleteResponse(String responseId) async {
    try {
      await _collection.doc(responseId).delete();
    } catch (e) {
      throw Exception('Failed to delete survey response: $e');
    }
  }

  @override
  Future<QuestionnaireResponse?> getLatestResponse({
    required String templateId,
    String? userId,
  }) async {
    try {
      final snapshot = await _collection
          .where('templateId', isEqualTo: templateId)
          .orderBy('startedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return _fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get latest survey response: $e');
    }
  }

  /// Convert a QuestionnaireResponse to a Firestore-compatible map
  /// Uses Firestore Timestamps for date fields for proper ordering/querying
  Map<String, dynamic> _toFirestore(QuestionnaireResponse response) {
    return {
      'id': response.id,
      'templateId': response.templateId,
      'userId': _firestoreService.currentUserId,
      'startedAt': Timestamp.fromDate(response.startedAt),
      'completedAt': response.completedAt != null
          ? Timestamp.fromDate(response.completedAt!)
          : null,
      'isComplete': response.isComplete,
      'answers': response.answers.map((answer) {
        return {
          'questionId': answer.questionId,
          'value': answer.value,
          'answeredAt': Timestamp.fromDate(answer.answeredAt),
        };
      }).toList(),
      if (response.associatedReadings != null)
        'associatedReadings':
            response.associatedReadings!.map((r) => r.toJson()).toList(),
      if (response.metadata != null) 'metadata': response.metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert a Firestore document to a QuestionnaireResponse
  QuestionnaireResponse _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    // Convert Firestore Timestamps back to the format expected by the model
    final Map<String, dynamic> jsonData = {
      'id': data['id'] as String,
      'templateId': data['templateId'] as String,
      'userId': data['userId'] as String,
      'startedAt': _timestampToIso(data['startedAt']),
      'isComplete': data['isComplete'] as bool? ?? false,
    };

    if (data['completedAt'] != null) {
      jsonData['completedAt'] = _timestampToIso(data['completedAt']);
    }

    // Convert answers with Timestamp handling
    final answers = (data['answers'] as List<dynamic>).map((a) {
      final answerMap = Map<String, dynamic>.from(a as Map<String, dynamic>);
      return {
        'questionId': answerMap['questionId'],
        'value': answerMap['value'],
        'answeredAt': _timestampToIso(answerMap['answeredAt']),
      };
    }).toList();
    jsonData['answers'] = answers;

    if (data['associatedReadings'] != null) {
      jsonData['associatedReadings'] = data['associatedReadings'];
    }

    if (data['metadata'] != null) {
      jsonData['metadata'] = data['metadata'];
    }

    return QuestionnaireResponse.fromJson(jsonData);
  }

  /// Helper to convert a Firestore Timestamp (or ISO string) to ISO 8601 string
  String _timestampToIso(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is String) {
      return value;
    }
    return DateTime.now().toIso8601String();
  }
}
