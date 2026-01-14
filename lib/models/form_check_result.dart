// =============================================================================
// form_check_result.dart — Data Model for Form Check Analysis
// =============================================================================

class FormCheckResult {
  final int overallScore; // 0-100
  final String summary;
  final List<String> errors;
  final List<String> corrections;
  final String youtubeSearchQuery;
  final List<String> analyzedFramePaths;

  const FormCheckResult({
    required this.overallScore,
    required this.summary,
    required this.errors,
    required this.corrections,
    required this.youtubeSearchQuery,
    this.analyzedFramePaths = const [],
  });

  factory FormCheckResult.fromJson(Map<String, dynamic> json) {
    return FormCheckResult(
      overallScore: (json['score'] as num?)?.toInt() ?? 50,
      summary: json['summary'] as String? ?? 'Анализ завершён',
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      corrections: (json['corrections'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      youtubeSearchQuery:
          json['youtube_query'] as String? ?? 'exercise form guide',
    );
  }

  Map<String, dynamic> toJson() => {
        'score': overallScore,
        'summary': summary,
        'errors': errors,
        'corrections': corrections,
        'youtube_query': youtubeSearchQuery,
      };

  /// Mock result for demo/fallback
  factory FormCheckResult.mock(String exerciseName) {
    return FormCheckResult(
      overallScore: 72,
      summary:
          'В целом техника выполнения $exerciseName на хорошем уровне, но есть несколько моментов для улучшения.',
      errors: [
        'Спина слегка округляется в нижней точке движения',
        'Колени выходят за линию носков',
        'Недостаточная глубина приседа',
      ],
      corrections: [
        'Держите грудь приподнятой, а плечи отведёнными назад',
        'Сфокусируйтесь на отведении таза назад, а не на сгибании коленей',
        'Старайтесь опускаться до параллели бёдер с полом',
        'Сделайте паузу в нижней точке для контроля',
      ],
      youtubeSearchQuery: '$exerciseName proper form tutorial',
    );
  }

  /// Perfect form result
  factory FormCheckResult.perfect(String exerciseName) {
    return FormCheckResult(
      overallScore: 95,
      summary: 'Отличная техника выполнения $exerciseName! Продолжайте в том же духе.',
      errors: [],
      corrections: [
        'Сохраняйте текущую технику',
        'Можете постепенно увеличивать нагрузку',
      ],
      youtubeSearchQuery: '$exerciseName advanced techniques',
    );
  }
}
