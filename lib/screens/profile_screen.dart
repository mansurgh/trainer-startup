// =============================================================================
// profile_screen.dart — Premium Dark Industrial Profile Screen
// =============================================================================
// SOTA-level profile screen featuring:
// - Full Sliver architecture (SliverAppBar + SliverToBoxAdapter + SliverGrid)
// - Discipline Rating with animated radial progress
// - Muscle Fatigue Map with interactive overlays
// - RPG Radar Chart for stats visualization
// - Glassmorphism 3.0 cards with BackdropFilter
// - ProfileProvider integration with Supabase auth sync
// - Liquid Glass iOS 26 design components
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/stats_provider.dart';
import '../models/user_model.dart';
import '../widgets/discipline_rating_widget.dart';
import '../widgets/muscle_map_svg_widget.dart';
import '../widgets/muscle_map_widget.dart' show MuscleData, generateSampleMuscleData;
import '../widgets/rpg_radar_chart_widget.dart';
import '../widgets/weight_input_sheet.dart';
import '../widgets/liquid_glass.dart' show GlassOfflineBanner, LiquidGlassCard;
import 'edit_profile_data_screen.dart';
import 'settings_screen.dart';
import 'progress_photo_gallery_screen.dart';
import 'workout_history_screen.dart';

// =============================================================================
// PROFILE SCREEN — Main Component
// =============================================================================

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  
  // UI state
  bool _showFrontBody = true;
  bool _isScrolled = false;

  // Sample data — in production, load from provider/API
  late Map<String, MuscleData> _muscleData;
  late List<RadarStat> _stats;
  int _disciplineScore = 850;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: kDurationSlow,
    )..forward();
    
    // Initialize sample data (will be updated from provider)
    _muscleData = generateSampleMuscleData();
    _stats = _generateUserStats();
    _disciplineScore = _calculateDisciplineScore();
    
    // Load real stats from Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statsProvider.notifier).loadStats();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 100;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  List<RadarStat> _generateUserStats() {
    // In production, calculate from actual user data
    return [
      FitnessStats.discipline.copyWith(value: 85),
      FitnessStats.nutrition.copyWith(value: 72),
      FitnessStats.strength.copyWith(value: 68),
      FitnessStats.endurance.copyWith(value: 65),
      FitnessStats.balance.copyWith(value: 58),
    ];
  }

  int _calculateDisciplineScore() {
    // Рейтинг строится из характеристик пятиугольника
    final discipline = _stats[0].value; // 0-100
    final nutrition = _stats[1].value;
    final strength = _stats[2].value;
    final endurance = _stats[3].value;
    final balance = _stats[4].value;
    
    // Формула: дисциплина * 4 + остальные * 2 = max 1000
    return ((discipline * 4) + 
            (nutrition * 2) + 
            (strength * 2) + 
            (endurance * 2) + 
            (balance * 2)).toInt();
  }

  void _toggleBodyView() {
    HapticFeedback.selectionClick();
    setState(() => _showFrontBody = !_showFrontBody);
  }

  void _openWeightPicker(UserModel? profile) async {
    final currentWeight = profile?.weight ?? 70.0;
    final result = await showWeightInputSheet(
      context,
      initialWeight: currentWeight,
      title: 'Обновить вес',
    );
    
    if (result != null && mounted) {
      ref.read(profileProvider.notifier).updateWeight(result);
    }
  }

  void _openSettings() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfileDataScreen(),
      ),
    );
  }
  
  Future<void> _changeAvatar() async {
    HapticFeedback.lightImpact();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusLG)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kTextTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text('Сменить аватар', style: kDenseHeading),
            const SizedBox(height: kSpaceLG),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpaceSM),
                decoration: BoxDecoration(
                  color: kElectricAmberStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                child: const Icon(Icons.camera_alt, color: kElectricAmberStart),
              ),
              title: Text('Сделать фото', style: kBodyText),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpaceSM),
                decoration: BoxDecoration(
                  color: kInfoCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                child: const Icon(Icons.photo_library, color: kInfoCyan),
              ),
              title: Text('Выбрать из галереи', style: kBodyText),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;

      // Показываем загрузку
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kTextPrimary,
                ),
              ),
              SizedBox(width: 12),
              Text('Загрузка аватара...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Загружаем аватар через провайдер
      await ref.read(profileProvider.notifier).updateAvatar(pickedFile.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Аватар обновлён!'),
            backgroundColor: kSuccessGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: kErrorRed,
          ),
        );
      }
    }
  }

  void _refreshProfile() async {
    HapticFeedback.mediumImpact();
    await ref.read(profileProvider.notifier).refresh();
    await ref.read(statsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final statsState = ref.watch(statsProvider);
    
    return Scaffold(
      backgroundColor: kOledBlack,
      body: Stack(
        children: [
          // Background with subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: kDarkBackgroundGradient,
            ),
          ),
          
          // Main scrollable content
          RefreshIndicator(
            onRefresh: () async => _refreshProfile(),
            color: kElectricAmberStart,
            backgroundColor: kObsidianSurface,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Premium SliverAppBar with parallax avatar
                _buildSliverAppBar(profile),
                
                // Loading indicator
                if (profileState.isLoading && !profileState.hasProfile)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: kElectricAmberStart),
                    ),
                  )
                else ...[
                  // Discipline Rating Section
                  SliverToBoxAdapter(
                    child: _buildDisciplineSection(statsState),
                  ),
                  
                  // Quick Stats Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                    sliver: _buildQuickStatsGrid(profile, statsState),
                  ),
                  
                  // Muscle Fatigue Map
                  SliverToBoxAdapter(
                    child: _buildMuscleFatigueSection(statsState),
                  ),
                  
                  // RPG Stats Radar
                  SliverToBoxAdapter(
                    child: _buildRpgStatsSection(statsState),
                  ),
                  
                  // Action Cards Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                    sliver: _buildActionCardsGrid(),
                  ),
                  
                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ],
            ),
          ),
          
          // Error banner (only if no cached data available)
          if (profileState.hasError && !profileState.hasProfile)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: kSpaceMD,
              right: kSpaceMD,
              child: GlassOfflineBanner(
                message: profileState.error!,
                onRetry: _refreshProfile,
              ),
            ),
          
          // Subtle offline indicator if using cached data
          if (profileState.hasError && profileState.hasProfile)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: kSpaceMD,
              right: kSpaceMD,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpaceSM,
                    vertical: kSpaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: kObsidianSurface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(kRadiusSM),
                    border: Border.all(
                      color: kWarningAmber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 14, color: kWarningAmber),
                      const SizedBox(width: kSpaceXS),
                      Text(
                        'Офлайн режим',
                        style: kCaptionText.copyWith(color: kWarningAmber, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SLIVER APP BAR — Premium Header
  // ===========================================================================

  Widget _buildSliverAppBar(UserModel? profile) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: _isScrolled ? kObsidianSurface : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.edit_outlined, size: 20),
        onPressed: _openSettings,
        color: kTextPrimary,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          color: kTextPrimary,
        ),
        const SizedBox(width: kSpaceSM),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: _ProfileHeaderBackground(
          profile: profile,
          onEditTap: _changeAvatar,
        ),
      ),
      title: _isScrolled
          ? Text(
              profile?.name ?? 'Профиль',
              style: kDenseSubheading.copyWith(fontSize: 18),
            )
          : null,
    );
  }

  // ===========================================================================
  // DISCIPLINE RATING SECTION
  // ===========================================================================

  Widget _buildDisciplineSection(StatsState statsState) {
    // Calculate discipline score from real characteristics
    final chars = statsState.characteristics;
    final hasRealData = chars.isNotEmpty && chars.values.any((v) => v > 10);
    
    int disciplineScore;
    Map<String, int> breakdown;
    
    if (hasRealData) {
      // Real score calculation based on characteristics
      final discipline = chars['discipline'] ?? 10.0;
      final nutrition = chars['nutrition'] ?? 10.0;
      final strength = chars['strength'] ?? 10.0;
      final endurance = chars['endurance'] ?? 10.0;
      final balance = chars['balance'] ?? 10.0;
      
      // Formula: discipline * 4 + others * 1.5 = max 1000
      disciplineScore = ((discipline * 4) + 
                         (nutrition * 1.5) + 
                         (strength * 1.5) + 
                         (endurance * 1.5) + 
                         (balance * 1.5)).toInt();
      
      breakdown = {
        'Постоянство': (discipline * 4).toInt(),
        'Питание': (nutrition * 1.5).toInt(),
        'Сила': (strength * 1.5).toInt(),
        'Выносливость': (endurance * 1.5).toInt(),
        'Баланс': (balance * 1.5).toInt(),
      };
    } else {
      disciplineScore = _disciplineScore;
      breakdown = {
        'Тренировки': 350,
        'Питание': 200,
        'Сон': 180,
        'Консистентность': 120,
      };
    }
    
    return Padding(
      padding: const EdgeInsets.all(kSpaceMD),
      child: GlassCard(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.military_tech, color: kElectricAmberStart, size: 24),
                const SizedBox(width: kSpaceSM),
                Text(
                  'Рейтинг Дисциплины',
                  style: kDenseSubheading.copyWith(fontSize: 18),
                ),
                const Spacer(),
                _InfoButton(
                  onTap: () => _showDisciplineInfo(context),
                ),
              ],
            ),
            const SizedBox(height: kSpaceLG),
            
            // Main discipline indicator
            DisciplineRatingWidget(
              score: disciplineScore,
              size: 200,
              strokeWidth: 14,
              showRankLabel: true,
            ),
            
            const SizedBox(height: kSpaceMD),
            
            // Score breakdown
            DisciplineBreakdown(
              components: breakdown,
            ),
          ],
        ),
      ),
    );
  }

  void _showDisciplineInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text('Как рассчитывается рейтинг?', style: kDenseHeading),
            const SizedBox(height: kSpaceMD),
            Text(
              'Рейтинг дисциплины — это показатель вашей последовательности и приверженности тренировкам.\n\n'
              '• Тренировки: до 400 очков за регулярные занятия\n'
              '• Питание: до 250 очков за соблюдение режима\n'
              '• Сон: до 200 очков за качественный отдых\n'
              '• Консистентность: до 150 очков за серии дней',
              style: kBodyText,
            ),
            const SizedBox(height: kSpaceLG),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // QUICK STATS GRID
  // ===========================================================================

  SliverGrid _buildQuickStatsGrid(UserModel? profile, StatsState statsState) {
    // Format weight change text
    String weightChangeText = '—';
    bool isWeightChangePositive = false;
    if (statsState.weightChange != null) {
      final change = statsState.weightChange!;
      final sign = change >= 0 ? '+' : '';
      weightChangeText = '$sign${change.toStringAsFixed(1)}';
      // For most goals, losing weight is positive
      isWeightChangePositive = profile?.goal == 'gain_muscle' ? change > 0 : change < 0;
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: kSpaceSM,
        mainAxisSpacing: kSpaceSM,
        childAspectRatio: 1.5,
      ),
      delegate: SliverChildListDelegate([
        // Weight card
        _QuickStatCard(
          icon: Icons.monitor_weight_outlined,
          label: 'Вес',
          value: profile?.weight?.toStringAsFixed(1) ?? '—',
          unit: 'кг',
          trend: weightChangeText,
          trendPositive: isWeightChangePositive,
          onTap: () => _openWeightPicker(profile),
        ),
        
        // Today's Win card with percentage
        _QuickStatCard(
          icon: Icons.star_outlined,
          label: 'Успех дня',
          value: '${statsState.successDayPercentage}',
          unit: '%',
          accentColor: statsState.successDayPercentage >= 70 
              ? kSuccessGreen 
              : statsState.successDayPercentage >= 30 
                  ? kElectricAmberStart 
                  : kTextTertiary,
          onTap: () => _showSuccessDayInfo(context, statsState),
          showInfoBadge: true,
        ),
        
        // Workouts this month
        _QuickStatCard(
          icon: Icons.fitness_center,
          label: 'Тренировки',
          value: '${statsState.workoutsThisMonth}',
          unit: '/ ${statsState.workoutsTarget}',
          accentColor: kSuccessGreen,
          onTap: () => _showWorkoutsInfo(context, statsState),
          showInfoBadge: true,
        ),
        
        // Streak
        _QuickStatCard(
          icon: Icons.local_fire_department,
          label: 'Серия',
          value: '${statsState.streak}',
          unit: 'дн',
          accentColor: statsState.streak > 0 ? kElectricAmberStart : kTextTertiary,
          onTap: () => _showStreakInfo(context, statsState),
          showInfoBadge: true,
        ),
      ]),
    );
  }

  // Info dialogs for stats
  void _showSuccessDayInfo(BuildContext context, StatsState statsState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text('Успех дня — ${statsState.successDayPercentage}%', style: kDenseHeading),
            const SizedBox(height: kSpaceMD),
            _buildSuccessRow('Вход в приложение', 10, statsState.successDayBreakdown['login'] ?? 0),
            _buildSuccessRow('Серия дней', 20, statsState.successDayBreakdown['streak'] ?? 0),
            _buildSuccessRow('Питание', 40, statsState.successDayBreakdown['nutrition'] ?? 0),
            _buildSuccessRow('Тренировка', 30, statsState.successDayBreakdown['workout'] ?? 0),
            const SizedBox(height: kSpaceMD),
            Text(
              'Выполняйте все активности, чтобы достичь 100%!',
              style: kCaptionText.copyWith(color: kTextTertiary),
            ),
            const SizedBox(height: kSpaceLG),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessRow(String label, int maxPercent, int currentPercent) {
    final isComplete = currentPercent >= maxPercent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            color: isComplete ? kSuccessGreen : kTextTertiary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: kBodyText)),
          Text(
            '$currentPercent / $maxPercent%',
            style: kCaptionText.copyWith(
              color: isComplete ? kSuccessGreen : kTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutsInfo(BuildContext context, StatsState statsState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text('Тренировки за месяц', style: kDenseHeading),
            const SizedBox(height: kSpaceMD),
            Row(
              children: [
                const Icon(Icons.fitness_center, color: kSuccessGreen, size: 28),
                const SizedBox(width: 12),
                Text(
                  '${statsState.workoutsThisMonth} из ${statsState.workoutsTarget}',
                  style: kDenseSubheading.copyWith(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: kSpaceMD),
            LinearProgressIndicator(
              value: statsState.workoutsThisMonth / statsState.workoutsTarget,
              backgroundColor: kObsidianBorder,
              valueColor: const AlwaysStoppedAnimation(kSuccessGreen),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: kSpaceMD),
            Text(
              'Цель: ${statsState.workoutsTarget} тренировок в месяц.\n'
              'Осталось: ${(statsState.workoutsTarget - statsState.workoutsThisMonth).clamp(0, statsState.workoutsTarget)} тренировок.',
              style: kBodyText.copyWith(color: kTextSecondary),
            ),
            const SizedBox(height: kSpaceLG),
          ],
        ),
      ),
    );
  }

  void _showStreakInfo(BuildContext context, StatsState statsState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text('Серия активности', style: kDenseHeading),
            const SizedBox(height: kSpaceMD),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: statsState.streak > 0 ? kElectricAmberStart : kTextTertiary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '${statsState.streak} дней подряд',
                  style: kDenseSubheading.copyWith(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: kSpaceMD),
            Text(
              'Серия засчитывается за каждый день, когда вы:\n'
              '• Завершили тренировку\n'
              '• Или записали приём пищи\n\n'
              'Поддерживайте серию, чтобы получить бонусы!',
              style: kBodyText.copyWith(color: kTextSecondary),
            ),
            const SizedBox(height: kSpaceLG),
          ],
        ),
      ),
    );
  }

  double _calculateGoalProgress(UserModel? profile) {
    if (profile?.weight == null || profile?.targetWeight == null) return 0;
    final initial = profile!.initialWeight ?? profile.weight!;
    final current = profile.weight!;
    final target = profile.targetWeight!;
    
    if (initial == target) return 1.0;
    return ((initial - current) / (initial - target)).clamp(0.0, 1.0);
  }

  // ===========================================================================
  // MUSCLE FATIGUE MAP SECTION
  // ===========================================================================

  Widget _buildMuscleFatigueSection(StatsState statsState) {
    // Map muscle group names from DB to widget keys
    final fatigueLevels = <String, double>{
      'chest': statsState.muscleFatigue['chest'] ?? 0.0,
      'abs': statsState.muscleFatigue['abs'] ?? statsState.muscleFatigue['core'] ?? 0.0,
      'shoulders': statsState.muscleFatigue['shoulders'] ?? 0.0,
      'arms': statsState.muscleFatigue['biceps'] ?? statsState.muscleFatigue['arms'] ?? 0.0,
      'legs': statsState.muscleFatigue['quadriceps'] ?? statsState.muscleFatigue['legs'] ?? 0.0,
    };
    
    // If no real data, use sample data
    final hasFatigueData = fatigueLevels.values.any((v) => v > 0);
    final displayLevels = hasFatigueData ? fatigueLevels : {
      'chest': _muscleData['chest']?.fatigueLevel ?? 0.0,
      'abs': _muscleData['abs']?.fatigueLevel ?? 0.0,
      'shoulders': _muscleData['shoulders']?.fatigueLevel ?? 0.0,
      'arms': _muscleData['biceps']?.fatigueLevel ?? 0.0,
      'legs': _muscleData['quadriceps']?.fatigueLevel ?? 0.0,
    };
    
    return Padding(
      padding: const EdgeInsets.all(kSpaceMD),
      child: GlassCard(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            Row(
              children: [
                const Icon(Icons.accessibility_new, color: kElectricAmberStart, size: 24),
                const SizedBox(width: kSpaceSM),
                Expanded(
                  child: Text(
                    'Карта Усталости',
                    style: kDenseSubheading.copyWith(fontSize: 16),
                  ),
                ),
                // Front/Back toggle
                _ToggleChip(
                  selected: _showFrontBody,
                  leftLabel: 'Перед',
                  rightLabel: 'Спина',
                  onToggle: _toggleBodyView,
                ),
              ],
            ),
            const SizedBox(height: kSpaceSM),
            
            // Data source indicator
            if (!hasFatigueData)
              Padding(
                padding: const EdgeInsets.only(bottom: kSpaceSM),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: kTextTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Начните тренировки для отображения реальных данных',
                      style: kCaptionText.copyWith(color: kTextTertiary, fontSize: 10),
                    ),
                  ],
                ),
              ),
            
            // Body map (SVG-based)
            AnimatedSwitcher(
              duration: kDurationMedium,
              child: MuscleMapWidget(
                key: ValueKey(_showFrontBody),
                fatigueLevels: displayLevels,
                showFront: _showFrontBody,
                height: 350,
                onMuscleTap: (muscleId) {
                  HapticFeedback.selectionClick();
                  final muscle = _muscleData[muscleId];
                  if (muscle != null) {
                    _showMuscleDetail(context, muscle);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMuscleDetail(BuildContext context, MuscleData muscle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
      builder: (context) => _MuscleDetailSheet(muscle: muscle),
    );
  }

  // ===========================================================================
  // RPG STATS SECTION
  // ===========================================================================

  Widget _buildRpgStatsSection(StatsState statsState) {
    // Build stats from real data
    final characteristics = statsState.characteristics;
    final hasRealData = characteristics.isNotEmpty && 
        characteristics.values.any((v) => v > 10);
    
    final realStats = [
      FitnessStats.discipline.copyWith(
        value: (characteristics['discipline'] ?? 10).toDouble(),
      ),
      FitnessStats.nutrition.copyWith(
        value: (characteristics['nutrition'] ?? 10).toDouble(),
      ),
      FitnessStats.strength.copyWith(
        value: (characteristics['strength'] ?? 10).toDouble(),
      ),
      FitnessStats.endurance.copyWith(
        value: (characteristics['endurance'] ?? 10).toDouble(),
      ),
      FitnessStats.balance.copyWith(
        value: (characteristics['balance'] ?? 10).toDouble(),
      ),
    ];
    
    return Padding(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasRealData)
            Padding(
              padding: const EdgeInsets.only(bottom: kSpaceSM, left: kSpaceSM),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: kTextTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Тренируйтесь для отображения реальных показателей',
                    style: kCaptionText.copyWith(color: kTextTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
          RpgRadarChartCard(
            stats: hasRealData ? realStats : _stats,
            title: 'Характеристики',
            onStatTap: (stat) {
              showStatDetailSheet(context, stat);
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTION CARDS GRID
  // ===========================================================================

  SliverGrid _buildActionCardsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: kSpaceMD,
        mainAxisSpacing: kSpaceMD,
        childAspectRatio: 1.2,
      ),
      delegate: SliverChildListDelegate([
        _ActionCard(
          icon: Icons.camera_alt_outlined,
          label: 'Прогресс фото',
          subtitle: '12 фото',
          gradient: LinearGradient(
            colors: [Colors.purple.withOpacity(0.3), Colors.transparent],
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressPhotoGalleryScreen()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.history,
          label: 'История',
          subtitle: '48 тренировок',
          gradient: LinearGradient(
            colors: [kInfoCyan.withOpacity(0.3), Colors.transparent],
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
            );
          },
        ),
      ]),
    );
  }
}

// =============================================================================
// SUPPORTING WIDGETS
// =============================================================================

/// Profile header background with avatar and info
class _ProfileHeaderBackground extends StatelessWidget {
  const _ProfileHeaderBackground({
    required this.profile,
    required this.onEditTap,
  });

  final UserModel? profile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kObsidianSurface.withOpacity(0.8),
            kOledBlack,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Avatar with glow
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kElectricAmberGradient,
                    boxShadow: [
                      BoxShadow(
                        color: kElectricAmberStart.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kObsidianSurface,
                      image: profile?.avatarPath != null
                          ? DecorationImage(
                              image: NetworkImage(profile!.avatarPath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile?.avatarPath == null
                        ? const Icon(
                            Icons.person,
                            size: 48,
                            color: kTextPrimary,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: kSpaceMD),
              
              // Name
              Text(
                profile?.name ?? 'Атлет',
                style: kDenseHeading,
              ),
              const SizedBox(height: kSpaceMD),
              
              // Quick badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProfileBadge(
                    icon: Icons.straighten,
                    value: '${profile?.height ?? '—'} см',
                  ),
                  const SizedBox(width: kSpaceMD),
                  _ProfileBadge(
                    icon: Icons.monitor_weight_outlined,
                    value: '${profile?.weight?.toStringAsFixed(1) ?? '—'} кг',
                  ),
                  const SizedBox(width: kSpaceMD),
                  _ProfileBadge(
                    icon: Icons.cake_outlined,
                    value: '${profile?.age ?? '—'} лет',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceSM, vertical: kSpaceXS),
      decoration: BoxDecoration(
        color: kObsidianSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(kRadiusFull),
        border: Border.all(color: kObsidianBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kTextTertiary),
          const SizedBox(width: 4),
          Text(value, style: kCaptionText.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Quick stat card for the grid
class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendPositive,
    this.progress,
    this.accentColor,
    this.onTap,
    this.showInfoBadge = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final String? trend;
  final bool? trendPositive;
  final double? progress;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool showInfoBadge;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? kElectricAmberStart;
    
    return ObsidianCard(
      onTap: onTap,
      padding: const EdgeInsets.all(kSpaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: kSpaceXS),
              Expanded(
                child: Text(
                  label,
                  style: kCaptionText.copyWith(color: kTextTertiary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showInfoBadge && onTap != null)
                Icon(Icons.info_outline, size: 14, color: kTextTertiary)
              else if (onTap != null)
                Icon(Icons.edit, size: 12, color: kTextTertiary),
            ],
          ),
          const Spacer(),
          
          // Value - wrapped in FittedBox to prevent overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: kLargeNumber.copyWith(fontSize: 28),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit!,
                    style: kCaptionText.copyWith(color: kTextTertiary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          
          // Trend or progress
          if (trend != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendPositive == true ? Icons.trending_down : Icons.trending_up,
                    size: 12,
                    color: trendPositive == true ? kSuccessGreen : kErrorRed,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend!,
                    style: kCaptionText.copyWith(
                      color: trendPositive == true ? kSuccessGreen : kErrorRed,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )
          else if (progress != null)
            AmberProgressBar(
              value: progress!,
              height: 4,
              showGlow: false,
            ),
        ],
      ),
    );
  }
}

/// Action card for bottom grid
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(kRadiusLG),
        child: Container(
          padding: const EdgeInsets.all(kSpaceMD),
          decoration: BoxDecoration(
            color: kObsidianSurface,
            borderRadius: BorderRadius.circular(kRadiusLG),
            border: Border.all(color: kObsidianBorder),
            gradient: gradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: kTextPrimary, size: 28),
              const Spacer(),
              Text(
                label,
                style: kBodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              Text(
                subtitle,
                style: kCaptionText.copyWith(color: kTextTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle chip for front/back body view
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.selected,
    required this.leftLabel,
    required this.rightLabel,
    required this.onToggle,
  });

  final bool selected;
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: kObsidianBorder,
          borderRadius: BorderRadius.circular(kRadiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(leftLabel, selected),
            _buildOption(rightLabel, !selected),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, bool isActive) {
    return AnimatedContainer(
      duration: kDurationFast,
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceXS),
      decoration: BoxDecoration(
        color: isActive ? kElectricAmberStart : Colors.transparent,
        borderRadius: BorderRadius.circular(kRadiusFull),
      ),
      child: Text(
        label,
        style: kCaptionText.copyWith(
          color: isActive ? kOledBlack : kTextTertiary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Info button
class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: kObsidianBorder.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.info_outline,
          size: 16,
          color: kTextTertiary,
        ),
      ),
    );
  }
}

/// Error banner
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSpaceMD),
      decoration: BoxDecoration(
        color: kErrorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: kErrorRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kErrorRed, size: 20),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: Text(
              message,
              style: kCaptionText.copyWith(color: kErrorRed),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Повторить',
              style: kCaptionText.copyWith(color: kElectricAmberStart),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muscle detail bottom sheet
class _MuscleDetailSheet extends StatelessWidget {
  const _MuscleDetailSheet({required this.muscle});

  final MuscleData muscle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSpaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kTextTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: kSpaceLG),
          
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                child: Icon(
                  Icons.accessibility_new,
                  color: _statusColor,
                ),
              ),
              const SizedBox(width: kSpaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(muscle.localizedName, style: kDenseHeading.copyWith(fontSize: 20)),
                    Text(muscle.statusText, style: kBodyText.copyWith(color: _statusColor)),
                  ],
                ),
              ),
              Text(
                '${muscle.recoveryPercent.round()}%',
                style: kLargeNumber.copyWith(color: _statusColor),
              ),
            ],
          ),
          
          const SizedBox(height: kSpaceLG),
          
          // Recovery progress
          AmberProgressBar(
            value: 1 - muscle.fatigueLevel,
            height: 12,
          ),
          
          const SizedBox(height: kSpaceMD),
          
          // Details
          Text(
            'Время восстановления: ~${muscle.recoveryHours} часов\n'
            'Последняя тренировка: ${muscle.hoursSinceWorkout ?? '—'} ч. назад',
            style: kBodyText,
          ),
          
          const SizedBox(height: kSpaceLG),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Тренировать сегодня'),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color get _statusColor {
    if (muscle.fatigueLevel < 0.3) return kSuccessGreen;
    if (muscle.fatigueLevel < 0.6) return kWarningAmber;
    return kErrorRed;
  }
}
