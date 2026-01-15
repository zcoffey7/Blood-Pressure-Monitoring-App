import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/questionnaire.dart';
import '../models/questionnaire_response.dart';
import '../repositories/questionnaire_repository.dart';

/// Controller for questionnaire data and state
/// Follows SRP - Only manages questionnaire state and user responses
/// Uses Provider for state management
class QuestionnaireController extends ChangeNotifier {
  final QuestionnaireRepository _repository;
  final String _userId; // For future multi-user support

  // State variables
  QuestionnaireTemplate? _currentTemplate;
  QuestionnaireResponse? _activeResponse;
  List<QuestionnaireResponse> _responseHistory = [];
  bool _isLoading = false;
  String? _error;
  final Uuid _uuid = const Uuid();

  QuestionnaireController(this._repository, {String userId = 'default_user'})
    : _userId = userId;

  // Getters
  QuestionnaireTemplate? get currentTemplate => _currentTemplate;
  QuestionnaireResponse? get activeResponse => _activeResponse;
  List<QuestionnaireResponse> get responseHistory => _responseHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveResponse => _activeResponse != null;
  bool get isActiveResponseComplete => _activeResponse?.isComplete ?? false;

  /// Load a questionnaire template and start a new response
  Future<void> startQuestionnaire(String templateId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load template
      _currentTemplate = await _repository.getTemplate(templateId);

      // Create new response
      _activeResponse = QuestionnaireResponse(
        id: _uuid.v4(),
        templateId: templateId,
        userId: _userId,
        answers: [],
        startedAt: DateTime.now(),
        isComplete: false,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to start questionnaire: $e';
      notifyListeners();
    }
  }

  /// Answer a question in the active response
  void answerQuestion({required String questionId, required dynamic value}) {
    if (_activeResponse == null) {
      _error = 'No active questionnaire';
      notifyListeners();
      return;
    }

    // Create or update answer
    final answer = QuestionAnswer(
      questionId: questionId,
      value: value,
      answeredAt: DateTime.now(),
    );

    // Remove existing answer for this question if it exists
    final updatedAnswers =
        _activeResponse!.answers
            .where((a) => a.questionId != questionId)
            .toList()
          ..add(answer);

    _activeResponse = _activeResponse!.copyWith(answers: updatedAnswers);

    _error = null;
    notifyListeners();
  }

  /// Get the current answer for a specific question
  dynamic getAnswer(String questionId) {
    return _activeResponse?.getAnswer(questionId)?.value;
  }

  /// Check if a question has been answered
  bool hasAnswer(String questionId) {
    return _activeResponse?.hasAnswer(questionId) ?? false;
  }

  /// Check if all required questions are answered
  bool areRequiredQuestionsAnswered() {
    if (_currentTemplate == null || _activeResponse == null) {
      return false;
    }

    final requiredQuestions = _currentTemplate!.questions
        .where((q) => q.required)
        .map((q) => q.id)
        .toList();

    return requiredQuestions.every(
      (questionId) => _activeResponse!.hasAnswer(questionId),
    );
  }

  /// Get list of unanswered required questions
  List<Question> getUnansweredRequiredQuestions() {
    if (_currentTemplate == null || _activeResponse == null) {
      return [];
    }

    return _currentTemplate!.questions
        .where((q) => q.required && !_activeResponse!.hasAnswer(q.id))
        .toList();
  }

  /// Submit the active questionnaire response
  Future<bool> submitQuestionnaire() async {
    if (_activeResponse == null) {
      _error = 'No active questionnaire to submit';
      notifyListeners();
      return false;
    }

    // Validate required questions
    if (!areRequiredQuestionsAnswered()) {
      _error = 'Please answer all required questions';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mark as complete
      _activeResponse = _activeResponse!.copyWith(
        completedAt: DateTime.now(),
        isComplete: true,
      );

      // Save to repository
      await _repository.saveResponse(_activeResponse!);

      // Add to history
      _responseHistory.insert(0, _activeResponse!);

      // Clear active response
      _activeResponse = null;
      _currentTemplate = null;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to submit questionnaire: $e';
      notifyListeners();
      return false;
    }
  }

  /// Save progress without completing (draft)
  Future<void> saveProgress() async {
    if (_activeResponse == null) {
      return;
    }

    try {
      await _repository.saveResponse(_activeResponse!);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save progress: $e';
      notifyListeners();
    }
  }

  /// Cancel the active questionnaire
  void cancelQuestionnaire() {
    _activeResponse = null;
    _currentTemplate = null;
    _error = null;
    notifyListeners();
  }

  /// Load response history for the current user
  Future<void> loadResponseHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (startDate != null && endDate != null) {
        _responseHistory = await _repository.getResponsesByDateRange(
          startDate: startDate,
          endDate: endDate,
          userId: _userId,
        );
      } else {
        _responseHistory = await _repository.getResponsesByUser(_userId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load response history: $e';
      notifyListeners();
    }
  }

  /// Get the most recent response for a specific template
  Future<QuestionnaireResponse?> getLatestResponse(String templateId) async {
    try {
      return await _repository.getLatestResponse(
        templateId: templateId,
        userId: _userId,
      );
    } catch (e) {
      _error = 'Failed to load latest response: $e';
      notifyListeners();
      return null;
    }
  }

  /// Load a specific response for viewing/editing
  Future<void> loadResponse(String responseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.getResponse(responseId);

      if (response == null) {
        throw Exception('Response not found');
      }

      // Load the associated template
      _currentTemplate = await _repository.getTemplate(response.templateId);

      // Set as active response if not complete (for editing)
      if (!response.isComplete) {
        _activeResponse = response;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load response: $e';
      notifyListeners();
    }
  }

  /// Delete a response from history
  Future<void> deleteResponse(String responseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteResponse(responseId);

      // Remove from local history
      _responseHistory.removeWhere((r) => r.id == responseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete response: $e';
      notifyListeners();
    }
  }

  /// Get statistics about responses
  Map<String, dynamic> getResponseStatistics() {
    if (_responseHistory.isEmpty) {
      return {'total': 0, 'thisWeek': 0, 'thisMonth': 0, 'completionRate': 0.0};
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final thisWeek = _responseHistory
        .where((r) => r.startedAt.isAfter(weekAgo))
        .length;

    final thisMonth = _responseHistory
        .where((r) => r.startedAt.isAfter(monthAgo))
        .length;

    final completed = _responseHistory.where((r) => r.isComplete).length;
    final completionRate = completed / _responseHistory.length;

    return {
      'total': _responseHistory.length,
      'thisWeek': thisWeek,
      'thisMonth': thisMonth,
      'completionRate': completionRate,
      'lastSubmitted': _responseHistory.isNotEmpty
          ? _responseHistory.first.completedAt
          : null,
    };
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadResponseHistory();
  }
}
