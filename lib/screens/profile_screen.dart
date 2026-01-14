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
import '../theme/noir_theme.dart' as noir;
import '../providers/profile_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/locale_provider.dart';
import '../models/user_model.dart';
import '../widgets/discipline_rating_widget.dart';
import '../widgets/muscle_map_svg_widget.dart';
import '../widgets/muscle_map_widget.dart' show MuscleData, generateSampleMuscleData;
import '../widgets/rpg_radar_chart_widget.dart';
import '../widgets/noir_weight_picker.dart';
import '../widgets/liquid_glass.dart' show GlassOfflineBanner, LiquidGlassCard;
import '../widgets/navigation/navigation.dart';
import '../widgets/history_row_widget.dart';
import '../services/noir_toast_service.dart';
import '../services/stats_service.dart';
import '../l10n/app_localizations.dart';
import 'edit_profile_data_screen.dart';
import 'settings_screen.dart';
import 'progress_photo_gallery_screen.dart';
import 'workout_history_screen.dart';
import 'nutrition_history_screen.dart';

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
    // Start with zeros for new users - real values come from provider
    return [
      FitnessStats.discipline.copyWith(value: 0),
      FitnessStats.nutrition.copyWith(value: 0),
      FitnessStats.strength.copyWith(value: 0),
      FitnessStats.endurance.copyWith(value: 0),
      FitnessStats.balance.copyWith(value: 0),
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
    final l10n = AppLocalizations.of(context)!;
    final currentWeight = profile?.weight ?? 70.0;
    final statsState = ref.read(statsProvider);
    
    // Calculate previous weight from weight change
    double? previousWeight;
    if (statsState.weightChange != null) {
      previousWeight = currentWeight - statsState.weightChange!;
    }
    
    final result = await NoirWeightPicker.show(
      context,
      initialWeightKg: currentWeight,
      previousWeightKg: previousWeight,
      targetWeightKg: profile?.targetWeight,
      goal: profile?.goal,
    );
    
    if (result != null && mounted) {
      await ref.read(profileProvider.notifier).updateWeight(result);
      // Refresh stats to get updated weight change
      await ref.read(statsProvider.notifier).refresh();
      // Show toast
      if (mounted) {
        NoirToast.success(context, l10n.dataSaved);
      }
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
    final l10n = AppLocalizations.of(context)!;
    
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
            Text(l10n.changeAvatar, style: kDenseHeading),
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
              title: Text(l10n.takePhotoCamera, style: kBodyText),
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
              title: Text(l10n.chooseFromGallery, style: kBodyText),
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
      NoirToast.info(context, l10n.loading);

      // Загружаем аватар через провайдер
      await ref.read(profileProvider.notifier).updateAvatar(pickedFile.path);
      
      if (mounted) {
        NoirToast.success(context, l10n.avatarUpdated);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        NoirToast.error(context, l10n.error);
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
    final l10n = AppLocalizations.of(context)!;
    
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
                _buildSliverAppBar(profile, l10n.athlete),
                
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
                  
                  // Nutrition History (Last 7 Days)
                  const SliverToBoxAdapter(
                    child: _NutritionHistoryWidget(),
                  ),
                  
                  // Progress Photos Gallery
                  SliverToBoxAdapter(
                    child: _ProgressPhotosSection(
                      onViewAll: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProgressPhotoGalleryScreen()),
                        );
                      },
                    ),
                  ),
                  
                  // RPG Stats Radar
                  SliverToBoxAdapter(
                    child: _buildRpgStatsSection(statsState),
                  ),
                  
                  // Action Cards Row
                  SliverToBoxAdapter(
                    child: _buildActionCardsSection(),
                  ),
                  
                  // Bottom spacing for floating nav bar
                  const SliverNavBarSpacer(),
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
                        AppLocalizations.of(context)!.offlineMode,
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

  Widget _buildSliverAppBar(UserModel? profile, String athleteFallback) {
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
          athleteFallback: athleteFallback,
          onEditTap: _changeAvatar,
        ),
      ),
      title: _isScrolled
          ? Text(
              profile?.name ?? athleteFallback,
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
    final hasRealData = chars.isNotEmpty && chars.values.any((v) => v > 0);
    
    int disciplineScore;
    Map<String, int> breakdown;
    final l10n = AppLocalizations.of(context)!;
    
    // Real score calculation based on characteristics (zeros for new users)
    final discipline = chars['discipline'] ?? 0.0;
    final nutrition = chars['nutrition'] ?? 0.0;
    final strength = chars['strength'] ?? 0.0;
    final endurance = chars['endurance'] ?? 0.0;
    final balance = chars['balance'] ?? 0.0;
    
    // Formula: discipline * 4 + others * 1.5 = max 1000
    disciplineScore = ((discipline * 4) + 
                       (nutrition * 1.5) + 
                       (strength * 1.5) + 
                       (endurance * 1.5) + 
                       (balance * 1.5)).toInt();
    
    breakdown = {
      l10n.consistencyLabel: (discipline * 4).toInt(),
      l10n.nutritionLabel: (nutrition * 1.5).toInt(),
      l10n.strengthLabel: (strength * 1.5).toInt(),
      l10n.enduranceLabel: (endurance * 1.5).toInt(),
      l10n.balanceLabel: (balance * 1.5).toInt(),
    };
    
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
                  l10n.disciplineRating,
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
            Text(AppLocalizations.of(context)!.howRatingCalculated, style: kDenseHeading),
            const SizedBox(height: kSpaceMD),
            Text(
              AppLocalizations.of(context)!.ratingExplanation,
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
    bool showTrendIcon = false;
    
    if (statsState.weightChange != null) {
      final change = statsState.weightChange!;
      // Only show trend if there's actual change (not 0.0)
      if (change.abs() >= 0.1) {
        final sign = change >= 0 ? '+' : '';
        weightChangeText = '$sign${change.toStringAsFixed(1)}';
        // For most goals, losing weight is positive
        isWeightChangePositive = profile?.goal == 'gain_muscle' ? change > 0 : change < 0;
        showTrendIcon = true;
      } else {
        // Change is negligible (~0), show no change indicator
        weightChangeText = '±0';
      }
    }
    
    final l10n = AppLocalizations.of(context)!;

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
          label: l10n.weight,
          value: profile?.weight?.toStringAsFixed(1) ?? '—',
          unit: l10n.kg,
          trend: weightChangeText,
          trendPositive: isWeightChangePositive,
          showTrendIcon: showTrendIcon,
          onTap: () => _openWeightPicker(profile),
        ),
        
        // Today's Win card with percentage
        _QuickStatCard(
          icon: Icons.star_outlined,
          label: l10n.todaysWin,
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
          label: l10n.workouts,
          value: '${statsState.workoutsThisMonth}',
          unit: '/ ${statsState.workoutsTarget}',
          accentColor: kSuccessGreen,
          onTap: () => _showWorkoutsInfo(context, statsState),
          showInfoBadge: true,
        ),
        
        // Streak
        _QuickStatCard(
          icon: Icons.local_fire_department,
          label: l10n.streak,
          value: '${statsState.streak}',
          unit: l10n.days,
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
            Text(AppLocalizations.of(context)!.successDayTitle(statsState.successDayPercentage), style: kDenseHeading),
            const SizedBox(height: kSpaceMD),
            _buildSuccessRow(AppLocalizations.of(context)!.appLogin, 10, statsState.successDayBreakdown['login'] ?? 0),
            _buildSuccessRow(AppLocalizations.of(context)!.streakDays, 20, statsState.successDayBreakdown['streak'] ?? 0),
            _buildSuccessRow(AppLocalizations.of(context)!.nutritionLabel, 40, statsState.successDayBreakdown['nutrition'] ?? 0),
            _buildSuccessRow(AppLocalizations.of(context)!.workoutActivity, 30, statsState.successDayBreakdown['workout'] ?? 0),
            const SizedBox(height: kSpaceMD),
            Text(
              AppLocalizations.of(context)!.completeAllForHundred,
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
            Text(AppLocalizations.of(context)!.workoutsThisMonth, style: kDenseHeading),
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
              '${AppLocalizations.of(context)!.monthlyGoal(statsState.workoutsTarget)}\n'
              '${AppLocalizations.of(context)!.workoutsRemaining((statsState.workoutsTarget - statsState.workoutsThisMonth).clamp(0, statsState.workoutsTarget))}',
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
            Text(AppLocalizations.of(context)!.activityStreak, style: kDenseHeading),
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
                  AppLocalizations.of(context)!.daysInRow(statsState.streak),
                  style: kDenseSubheading.copyWith(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: kSpaceMD),
            Text(
              AppLocalizations.of(context)!.streakExplanation,
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

  /// Calculate goal progress as integer percentage
  int _calculateGoalProgressPercent(UserModel? profile) {
    if (profile?.weight == null || profile?.targetWeight == null) return 0;
    final initial = profile!.initialWeight ?? profile.weight!;
    final current = profile.weight!;
    final target = profile.targetWeight!;
    
    if (initial == target) return 100;
    final progress = ((initial - current) / (initial - target)).clamp(0.0, 1.0);
    return (progress * 100).toInt();
  }

  // Legacy method for backward compatibility
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
    final l10n = AppLocalizations.of(context)!;
    
    // Build stats from real data - start at 0 for new users
    final characteristics = statsState.characteristics;
    final hasRealData = characteristics.isNotEmpty && 
        characteristics.values.any((v) => v > 0);
    
    // For new users, show zeros (not fake 10s)
    // Use localized names and descriptions
    final realStats = [
      RadarStat(
        name: 'discipline',
        localizedName: l10n.discipline,
        value: (characteristics['discipline'] ?? 0).toDouble(),
        maxValue: 100,
        icon: Icons.psychology,
        description: l10n.disciplineDesc,
      ),
      RadarStat(
        name: 'nutrition',
        localizedName: l10n.nutritionLabel,
        value: (characteristics['nutrition'] ?? 0).toDouble(),
        maxValue: 100,
        icon: Icons.restaurant,
        description: l10n.nutritionDesc,
      ),
      RadarStat(
        name: 'strength',
        localizedName: l10n.strengthLabel,
        value: (characteristics['strength'] ?? 0).toDouble(),
        maxValue: 100,
        icon: Icons.fitness_center,
        description: l10n.strengthDesc,
      ),
      RadarStat(
        name: 'endurance',
        localizedName: l10n.enduranceLabel,
        value: (characteristics['endurance'] ?? 0).toDouble(),
        maxValue: 100,
        icon: Icons.directions_run,
        description: l10n.enduranceDesc,
      ),
      RadarStat(
        name: 'balance',
        localizedName: l10n.balanceLabel,
        value: (characteristics['balance'] ?? 0).toDouble(),
        maxValue: 100,
        icon: Icons.balance,
        description: l10n.balanceDesc,
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
                    l10n.trainToSeeStats,
                    style: kCaptionText.copyWith(color: kTextTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
          RpgRadarChartCard(
            stats: realStats, // Always show real stats (zeros for new users)
            title: l10n.characteristics,
            onStatTap: (stat) {
              showStatDetailSheet(context, stat);
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTION CARDS GRID — Now Rectangular History Rows
  // ===========================================================================

  Widget _buildActionCardsSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
      child: Column(
        children: [
          // Workout History Row
          _WorkoutHistoryRow(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
              );
            },
          ),
          const SizedBox(height: kSpaceMD),
        ],
      ),
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
    required this.athleteFallback,
    required this.onEditTap,
  });

  final UserModel? profile;
  final String athleteFallback;
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
                profile?.name ?? athleteFallback,
                style: kDenseHeading,
              ),
              const SizedBox(height: kSpaceMD),
              
              // Quick badges (localized units)
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileBadge(
                        icon: Icons.straighten,
                        value: '${profile?.height ?? '—'} ${l10n.cmUnit}',
                      ),
                      const SizedBox(width: kSpaceMD),
                      _ProfileBadge(
                        icon: Icons.monitor_weight_outlined,
                        value: '${profile?.weight?.toStringAsFixed(1) ?? '—'} ${l10n.kgUnit}',
                      ),
                      const SizedBox(width: kSpaceMD),
                      _ProfileBadge(
                        icon: Icons.cake_outlined,
                        value: '${profile?.age ?? '—'} ${l10n.yearsUnit}',
                      ),
                    ],
                  );
                },
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
    this.showTrendIcon = true,
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
  final bool showTrendIcon;
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
          if (trend != null && trend != '—')
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showTrendIcon) ...[
                    Icon(
                      trendPositive == true ? Icons.trending_down : Icons.trending_up,
                      size: 12,
                      color: trendPositive == true ? kSuccessGreen : kErrorRed,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    trend!,
                    style: kCaptionText.copyWith(
                      color: showTrendIcon 
                          ? (trendPositive == true ? kSuccessGreen : kErrorRed)
                          : kTextTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )
          else if (trend == '—')
            Text(
              '—',
              style: kCaptionText.copyWith(
                color: kTextTertiary,
                fontSize: 10,
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

// =============================================================================
// _NutritionHistoryWidget — Clickable Row with 7-Day Bar Chart
// =============================================================================

class _NutritionHistoryWidget extends ConsumerStatefulWidget {
  const _NutritionHistoryWidget();

  @override
  ConsumerState<_NutritionHistoryWidget> createState() => _NutritionHistoryWidgetState();
}

class _NutritionHistoryWidgetState extends ConsumerState<_NutritionHistoryWidget> {
  List<HistoryDayData> _days = [];
  bool _isLoading = true;
  String? _error;
  final _statsService = StatsService();

  @override
  void initState() {
    super.initState();
    _loadNutritionHistory();
  }

  Future<void> _loadNutritionHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _statsService.getLast7DaysNutrition();
      if (mounted) {
        setState(() {
          _days = data.map((item) {
            final map = item as Map<String, dynamic>;
            return HistoryDayData(
              date: DateTime(map['year'] as int, map['month'] as int, map['day'] as int),
              value: (map['calories'] as int).toDouble(),
              target: (map['target'] as int).toDouble(),
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _days = _generateEmptyDays();
        });
      }
    }
  }

  List<HistoryDayData> _generateEmptyDays() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return HistoryDayData(date: date, value: 0, target: 2000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: noir.kSpaceMD, vertical: noir.kSpaceSM),
      child: HistoryRowWidget(
        title: l10n.nutritionHistory,
        subtitle: l10n.last7Days,
        icon: Icons.restaurant_menu_rounded,
        days: _days,
        isLoading: _isLoading,
        barColor: const Color(0xFF4ADE80), // Green for nutrition
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NutritionHistoryScreen()),
          );
        },
      ),
    );
  }
}

// =============================================================================
// _WorkoutHistoryRow — Clickable Row with 7-Day Workout Chart
// =============================================================================

class _WorkoutHistoryRow extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  
  const _WorkoutHistoryRow({required this.onTap});

  @override
  ConsumerState<_WorkoutHistoryRow> createState() => _WorkoutHistoryRowState();
}

class _WorkoutHistoryRowState extends ConsumerState<_WorkoutHistoryRow> {
  List<HistoryDayData> _days = [];
  bool _isLoading = true;
  final _statsService = StatsService();

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _statsService.getLast7DaysWorkouts();
      if (mounted) {
        setState(() {
          _days = data.map((item) {
            final map = item as Map<String, dynamic>;
            return HistoryDayData(
              date: DateTime(map['year'] as int, map['month'] as int, map['day'] as int),
              value: (map['workouts'] as int).toDouble(),
              target: 1.0, // 1 workout per day is 100%
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _days = _generateEmptyDays();
        });
      }
    }
  }

  List<HistoryDayData> _generateEmptyDays() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return HistoryDayData(date: date, value: 0, target: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return HistoryRowWidget(
      title: l10n.workoutHistory,
      subtitle: l10n.last7Days,
      icon: Icons.fitness_center_rounded,
      days: _days,
      isLoading: _isLoading,
      barColor: kInfoCyan, // Cyan for workouts
      onTap: widget.onTap,
    );
  }
}

// =============================================================================
// _ProgressPhotosSection — Inline Noir Glass Horizontal Gallery
// =============================================================================

class _ProgressPhotosSection extends ConsumerStatefulWidget {
  final VoidCallback onViewAll;
  
  const _ProgressPhotosSection({required this.onViewAll});

  @override
  ConsumerState<_ProgressPhotosSection> createState() => _ProgressPhotosSectionState();
}

class _ProgressPhotosSectionState extends ConsumerState<_ProgressPhotosSection> {
  List<ProgressPhoto> _photos = [];
  bool _isLoading = true;
  String? _error;
  final _statsService = StatsService();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final photosData = await _statsService.getProgressPhotos(limit: 10);
      if (mounted) {
        setState(() {
          _photos = photosData
              .map((json) {
                try {
                  return ProgressPhoto.fromJson(json);
                } catch (_) {
                  return null;
                }
              })
              .whereType<ProgressPhoto>()
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle missing table or other DB errors gracefully
      if (mounted) {
        setState(() {
          _photos = []; // Show empty state instead of error
          _error = null; // Don't show error, just empty
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: noir.kSpaceMD, vertical: noir.kSpaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined, color: noir.kContentMedium, size: 20),
                  const SizedBox(width: noir.kSpaceSM),
                  Text(
                    l10n.progressPhotos,
                    style: noir.kNoirHeadline.copyWith(fontSize: 18),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.onViewAll,
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(color: noir.kContentMedium, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: noir.kSpaceSM),
          
          // Horizontal gallery - fixed 180px height
          SizedBox(
            height: 180,
            child: _buildGalleryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(noir.kContentMedium.withOpacity(0.5)),
        ),
      );
    }
    
    if (_error != null) {
      return _buildEmptyState(l10n.errorLoadingPhotos);
    }
    
    if (_photos.isEmpty) {
      return _buildEmptyState(l10n.noProgressPhotosYet);
    }
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _photos.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddButton();
        }
        return _buildPhotoItem(_photos[index - 1]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return GestureDetector(
      onTap: widget.onViewAll,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(noir.kRadiusMD),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: noir.kNoirGraphite.withOpacity(0.4),
              borderRadius: BorderRadius.circular(noir.kRadiusMD),
              border: Border.all(color: noir.kNoirSteel.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: noir.kContentLow,
                  size: 40,
                ),
                const SizedBox(height: noir.kSpaceSM),
                Text(
                  message,
                  style: const TextStyle(color: noir.kContentLow, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: noir.kSpaceXS),
                Text(
                  AppLocalizations.of(context)!.tapToAdd,
                  style: TextStyle(color: noir.kContentLow.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: widget.onViewAll,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: noir.kSpaceSM),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(noir.kRadiusMD),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: noir.kNoirGraphite.withOpacity(0.4),
                borderRadius: BorderRadius.circular(noir.kRadiusMD),
                border: Border.all(color: noir.kNoirSteel.withOpacity(0.3)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: noir.kContentMedium,
                    size: 32,
                  ),
                  SizedBox(height: noir.kSpaceXS),
                  Text(
                    'Добавить',
                    style: TextStyle(color: noir.kContentMedium, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(ProgressPhoto photo) {
    // Safety check for empty URL
    final photoUrl = photo.photoUrl;
    if (photoUrl.isEmpty) {
      return _buildBrokenPhotoPlaceholder();
    }
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgressPhotoGalleryScreen()),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: noir.kSpaceSM),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(noir.kRadiusMD),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo with error handling
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: noir.kNoirGraphite,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation(noir.kContentLow),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stack) {
                  return Container(
                    color: noir.kNoirGraphite,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: noir.kContentLow,
                      size: 32,
                    ),
                  );
                },
              ),
              
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        noir.kNoirBlack.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Date label
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  _formatDate(photo.createdAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Weight badge if available
              if (photo.weight != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: noir.kNoirBlack.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${photo.weight!.toStringAsFixed(1)} кг',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBrokenPhotoPlaceholder() {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: noir.kSpaceSM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(noir.kRadiusMD),
        child: Container(
          color: noir.kNoirGraphite,
          child: const Icon(
            Icons.broken_image_outlined,
            color: noir.kContentLow,
            size: 32,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

