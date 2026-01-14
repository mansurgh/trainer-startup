import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Workout History Screen - история тренировок
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  final _supabase = Supabase.instance.client;
  List<WorkoutSession> _workouts = [];
  bool _isLoading = true;
  String? _error;
  
  // Stats
  int _totalWorkouts = 0;
  int _thisMonthWorkouts = 0;
  Duration _totalDuration = Duration.zero;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(AppLocalizations.of(context)?.userNotAuthorized ?? 'User not authorized');
      }

      final response = await _supabase
          .from('workout_sessions')
          .select()
          .eq('user_id', userId)
          .order('workout_date', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      
      final workouts = data.map((json) => WorkoutSession.fromJson(json)).toList();
      
      // Рассчитываем статистику
      _calculateStats(workouts);
      
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = '${l10n?.error ?? "Error"}: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateStats(List<WorkoutSession> workouts) {
    _totalWorkouts = workouts.length;
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    _thisMonthWorkouts = workouts.where((w) {
      return w.startedAt.isAfter(thisMonth);
    }).length;
    
    _totalDuration = workouts.fold(Duration.zero, (total, w) {
      return total + (w.duration ?? Duration.zero);
    });
    
    // Рассчитываем текущую серию
    _currentStreak = _calculateStreak(workouts);
  }

  int _calculateStreak(List<WorkoutSession> workouts) {
    if (workouts.isEmpty) return 0;
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final workout in workouts) {
      final workoutDate = DateTime(
        workout.startedAt.year,
        workout.startedAt.month,
        workout.startedAt.day,
      );
      
      if (lastDate == null) {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final diff = today.difference(workoutDate).inDays;
        if (diff <= 1) {
          streak = 1;
          lastDate = workoutDate;
        } else {
          break;
        }
      } else {
        final diff = lastDate.difference(workoutDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = workoutDate;
        } else if (diff == 0) {
          // Несколько тренировок в один день
          continue;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  void _openWorkoutDetails(WorkoutSession workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _WorkoutDetailScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kOledBlack,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: kOledBlack,
            title: Text(l10n.workoutHistory, style: kDenseHeading),
            floating: true,
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildStatsHeader(),
            ),
          ),
          
          // Content
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kObsidianSurface.withOpacity(0.5),
            kOledBlack,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kSpaceMD, 56, kSpaceMD, kSpaceMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBadge(
                icon: Icons.fitness_center,
                value: '$_totalWorkouts',
                label: l10n.totalWorkouts,
                color: kElectricAmberStart,
              ),
              _StatBadge(
                icon: Icons.calendar_month,
                value: '$_thisMonthWorkouts',
                label: l10n.thisMonth,
                color: kInfoCyan,
              ),
              _StatBadge(
                icon: Icons.timer,
                value: _formatTotalDuration(),
                label: l10n.time,
                color: kSuccessGreen,
              ),
              _StatBadge(
                icon: Icons.local_fire_department,
                value: '$_currentStreak',
                label: l10n.streak,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTotalDuration() {
    final hours = _totalDuration.inHours;
    if (hours < 1) {
      return '${_totalDuration.inMinutes}м';
    }
    return '${hours}ч';
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: kElectricAmberStart),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: kErrorRed),
              const SizedBox(height: kSpaceMD),
              Text(_error!, style: kBodyText.copyWith(color: kTextSecondary)),
              const SizedBox(height: kSpaceMD),
              ElevatedButton(
                onPressed: _loadWorkouts,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_workouts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: kObsidianSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: kTextTertiary,
                ),
              ),
              const SizedBox(height: kSpaceLG),
              Text(
                l10n.noWorkouts,
                style: kDenseHeading.copyWith(color: kTextSecondary),
              ),
              const SizedBox(height: kSpaceSM),
              Text(
                l10n.startWorkingOutHint,
                style: kBodyText.copyWith(color: kTextTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Группируем по месяцам
    final groupedWorkouts = _groupByMonth(_workouts);
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = groupedWorkouts.entries.elementAt(index);
          return _MonthSection(
            monthYear: entry.key,
            workouts: entry.value,
            onWorkoutTap: _openWorkoutDetails,
          );
        },
        childCount: groupedWorkouts.length,
      ),
    );
  }

  Map<String, List<WorkoutSession>> _groupByMonth(List<WorkoutSession> workouts) {
    final Map<String, List<WorkoutSession>> grouped = {};
    
    for (final workout in workouts) {
      final key = _getMonthYearKey(workout.startedAt);
      grouped.putIfAbsent(key, () => []).add(workout);
    }
    
    return grouped;
  }

  String _getMonthYearKey(DateTime date) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      final monthsEn = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${monthsEn[date.month - 1]} ${date.year}';
    }
    final months = [
      l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
      l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// =============================================================================
// SUPPORTING WIDGETS
// =============================================================================

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(kSpaceSM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: kSpaceXS),
        Text(
          value,
          style: kLargeNumber.copyWith(fontSize: 20, color: kTextPrimary),
        ),
        Text(
          label,
          style: kCaptionText.copyWith(color: kTextTertiary, fontSize: 10),
        ),
      ],
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.monthYear,
    required this.workouts,
    required this.onWorkoutTap,
  });

  final String monthYear;
  final List<WorkoutSession> workouts;
  final Function(WorkoutSession) onWorkoutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceMD, kSpaceMD, kSpaceSM),
          child: Row(
            children: [
              Text(
                monthYear,
                style: kDenseHeading.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpaceSM, vertical: kSpaceXS),
                decoration: BoxDecoration(
                  color: kElectricAmberStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusFull),
                ),
                child: Text(
                  '${workouts.length} тр.',
                  style: kCaptionText.copyWith(color: kElectricAmberStart),
                ),
              ),
            ],
          ),
        ),
        ...workouts.map((w) => _WorkoutCard(
          workout: w,
          onTap: () => onWorkoutTap(w),
        )),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.onTap,
  });

  final WorkoutSession workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceXS),
      child: ObsidianCard(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        padding: const EdgeInsets.all(kSpaceMD),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(kRadiusMD),
              ),
              child: Icon(
                _getTypeIcon(),
                color: _getTypeColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: kSpaceMD),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.workoutType ?? 'Тренировка',
                    style: kBodyText.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: kTextTertiary),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(workout.startedAt),
                        style: kCaptionText.copyWith(color: kTextTertiary),
                      ),
                      const SizedBox(width: kSpaceSM),
                      if (workout.duration != null) ...[
                        Icon(Icons.timer_outlined, size: 12, color: kTextTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(workout.duration!),
                          style: kCaptionText.copyWith(color: kTextTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (workout.caloriesBurned != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.caloriesBurned}',
                        style: kCaptionText.copyWith(
                          color: kTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                if (workout.exercisesCount != null)
                  Text(
                    '${workout.exercisesCount} упр.',
                    style: kCaptionText.copyWith(color: kTextTertiary),
                  ),
              ],
            ),
            
            const SizedBox(width: kSpaceSM),
            Icon(Icons.chevron_right, color: kTextTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (workout.workoutType?.toLowerCase()) {
      case 'силовая':
      case 'strength':
        return Icons.fitness_center;
      case 'кардио':
      case 'cardio':
        return Icons.directions_run;
      case 'йога':
      case 'yoga':
        return Icons.self_improvement;
      case 'растяжка':
      case 'stretch':
        return Icons.accessibility_new;
      case 'hiit':
        return Icons.flash_on;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getTypeColor() {
    switch (workout.workoutType?.toLowerCase()) {
      case 'силовая':
      case 'strength':
        return kElectricAmberStart;
      case 'кардио':
      case 'cardio':
        return kErrorRed;
      case 'йога':
      case 'yoga':
        return Colors.purple;
      case 'растяжка':
      case 'stretch':
        return kInfoCyan;
      case 'hiit':
        return Colors.orange;
      default:
        return kElectricAmberStart;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')} в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}ч ${duration.inMinutes % 60}м';
    }
    return '${duration.inMinutes}м';
  }
}

// =============================================================================
// WORKOUT DETAIL SCREEN
// =============================================================================

class _WorkoutDetailScreen extends StatelessWidget {
  const _WorkoutDetailScreen({required this.workout});

  final WorkoutSession workout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOledBlack,
      appBar: AppBar(
        backgroundColor: kOledBlack,
        title: Text(workout.workoutType ?? 'Тренировка', style: kDenseHeading),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kSpaceMD),
        children: [
          // Header card
          ObsidianCard(
            padding: const EdgeInsets.all(kSpaceLG),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DetailStat(
                      icon: Icons.access_time,
                      value: _formatDateTime(workout.startedAt),
                      label: 'Дата и время',
                    ),
                    if (workout.duration != null)
                      _DetailStat(
                        icon: Icons.timer,
                        value: _formatDuration(workout.duration!),
                        label: 'Длительность',
                      ),
                  ],
                ),
                if (workout.caloriesBurned != null || workout.exercisesCount != null) ...[
                  const SizedBox(height: kSpaceLG),
                  const Divider(color: kObsidianBorder),
                  const SizedBox(height: kSpaceLG),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (workout.caloriesBurned != null)
                        _DetailStat(
                          icon: Icons.local_fire_department,
                          value: '${workout.caloriesBurned}',
                          label: 'Калории',
                          color: Colors.orange,
                        ),
                      if (workout.exercisesCount != null)
                        _DetailStat(
                          icon: Icons.format_list_numbered,
                          value: '${workout.exercisesCount}',
                          label: 'Упражнения',
                          color: kInfoCyan,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Notes
          if (workout.notes != null && workout.notes!.isNotEmpty) ...[
            const SizedBox(height: kSpaceMD),
            ObsidianCard(
              padding: const EdgeInsets.all(kSpaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, size: 18, color: kTextTertiary),
                      const SizedBox(width: kSpaceSM),
                      Text(
                        'Заметки',
                        style: kCaptionText.copyWith(color: kTextTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: kSpaceSM),
                  Text(
                    workout.notes!,
                    style: kBodyText,
                  ),
                ],
              ),
            ),
          ],
          
          // Placeholder for exercises list
          const SizedBox(height: kSpaceMD),
          ObsidianCard(
            padding: const EdgeInsets.all(kSpaceLG),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: kTextTertiary,
                ),
                const SizedBox(height: kSpaceMD),
                Text(
                  'Список упражнений',
                  style: kBodyText.copyWith(color: kTextSecondary),
                ),
                const SizedBox(height: kSpaceXS),
                Text(
                  'Детализация упражнений будет доступна\nв следующем обновлении',
                  style: kCaptionText.copyWith(color: kTextTertiary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}ч ${duration.inMinutes % 60}м';
    }
    return '${duration.inMinutes} мин';
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? kElectricAmberStart;
    
    return Column(
      children: [
        Icon(icon, color: c, size: 24),
        const SizedBox(height: kSpaceSM),
        Text(
          value,
          style: kBodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: kCaptionText.copyWith(color: kTextTertiary),
        ),
      ],
    );
  }
}

// =============================================================================
// DATA MODEL
// =============================================================================

class WorkoutSession {
  final String id;
  final String userId;
  final String? workoutType;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Duration? duration;
  final int? caloriesBurned;
  final int? exercisesCount;
  final String? notes;
  final String? status;

  WorkoutSession({
    required this.id,
    required this.userId,
    this.workoutType,
    required this.startedAt,
    this.finishedAt,
    this.duration,
    this.caloriesBurned,
    this.exercisesCount,
    this.notes,
    this.status,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    DateTime? finishedAt;
    if (json['completed_at'] != null) {
      finishedAt = DateTime.parse(json['completed_at'] as String);
    }
    
    // workout_date + created_at time
    DateTime startedAt;
    if (json['workout_date'] != null) {
      startedAt = DateTime.parse(json['workout_date'] as String);
      // Add time from created_at if available
      if (json['created_at'] != null) {
        final createdAt = DateTime.parse(json['created_at'] as String);
        startedAt = DateTime(
          startedAt.year, startedAt.month, startedAt.day,
          createdAt.hour, createdAt.minute,
        );
      }
    } else if (json['started_at'] != null) {
      startedAt = DateTime.parse(json['started_at'] as String);
    } else {
      startedAt = DateTime.parse(json['created_at'] as String);
    }
    
    Duration? duration;
    if (json['duration_minutes'] != null) {
      duration = Duration(minutes: json['duration_minutes'] as int);
    } else if (json['duration_seconds'] != null) {
      duration = Duration(seconds: json['duration_seconds'] as int);
    }
    
    return WorkoutSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutType: json['workout_type'] as String? ?? json['day_of_week'] as String?,
      startedAt: startedAt,
      finishedAt: finishedAt,
      duration: duration,
      caloriesBurned: json['calories_burned'] as int?,
      exercisesCount: json['exercises_completed'] as int? ?? json['exercises_count'] as int?,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
    );
  }
}
