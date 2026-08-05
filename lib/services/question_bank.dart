import '../models/learning/challenge.dart';
import 'local_question_db.dart';
import 'app_logger.dart';

/// Central question repository for quiz sessions.
class QuestionBank {
  static final QuestionBank instance = QuestionBank._();
  QuestionBank._();

  final AppLogger _logger = AppLogger();

  /// Returns questions from LocalQuestionDB only. No hardcoded fallback.
  Future<List<Challenge>> getQuestionsForLesson(String stageId, String lessonId, {int count = 5}) async {
    try {
      final dbQuestions = await LocalQuestionDB.instance.getQuestionsForLesson(stageId, lessonId, count: count);
      if (dbQuestions.isNotEmpty) return dbQuestions;
      _logger.warning('QuestionBank: no questions found for $stageId/$lessonId');
    } catch (e) {
      _logger.error('QuestionBank: failed to load questions for $stageId/$lessonId', e);
    }
    return const [];
  }

  Future<Challenge?> getById(String id) async {
    return LocalQuestionDB.instance.getById(id);
  }

  Future<List<Challenge>> getByIds(List<String> ids) async {
    return LocalQuestionDB.instance.getByIds(ids);
  }
}
