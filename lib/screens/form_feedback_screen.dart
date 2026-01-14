// =============================================================================
// form_feedback_screen.dart — AI Form Check Results
// =============================================================================
// Displays AI analysis results:
// - Errors detected (bulleted list)
// - Corrections (green text)
// - YouTube guide button
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../theme/noir_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/noir_glass_components.dart';
import '../services/ai_service.dart';
import '../services/noir_toast_service.dart' show NoirToast;
import '../models/form_check_result.dart';

class FormFeedbackScreen extends StatefulWidget {
  const FormFeedbackScreen({
    super.key,
    required this.videoPath,
    required this.exerciseName,
  });

  final String? videoPath; // Nullable for desktop fallback
  final String exerciseName;

  @override
  State<FormFeedbackScreen> createState() => _FormFeedbackScreenState();
}

class _FormFeedbackScreenState extends State<FormFeedbackScreen> {
  VideoPlayerController? _videoController;
  bool _isAnalyzing = true;
  FormCheckResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initializeVideoPlayer();
    }
    _analyzeForm();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    // Clean up temp video file
    _cleanupVideo();
    super.dispose();
  }

  Future<void> _cleanupVideo() async {
    if (widget.videoPath == null) return;
    try {
      final file = File(widget.videoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoPath == null) return;
    
    _videoController = VideoPlayerController.file(File(widget.videoPath!));
    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();
      if (mounted) setState(() {});
    } catch (e) {
      // Video preview is optional, continue without it
    }
  }

  Future<void> _analyzeForm() async {
    try {
      final aiService = AIService();
      final result = await aiService.analyzeExerciseForm(
        widget.videoPath,
        widget.exerciseName,
      );
      
      if (mounted) {
        setState(() {
          _result = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _openYouTubeGuide() async {
    HapticFeedback.lightImpact();
    
    final searchQuery = _result?.youtubeSearchQuery ?? 
        '${widget.exerciseName} form guide';
    final encodedQuery = Uri.encodeComponent(searchQuery);
    final url = 'https://www.youtube.com/results?search_query=$encodedQuery';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          NoirToast.error(context, 'Не удалось открыть YouTube');
        }
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, 'Ошибка: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(l10n),
            
            // Content
            Expanded(
              child: _isAnalyzing
                  ? _buildLoadingState(l10n)
                  : _error != null
                      ? _buildErrorState(l10n)
                      : _buildResultsState(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kNoirCarbon.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: kBorderLight),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: kContentHigh),
            ),
          ),
          const SizedBox(width: kSpaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Анализ техники',
                  style: kNoirTitleMedium.copyWith(color: kContentHigh),
                ),
                Text(
                  widget.exerciseName,
                  style: kNoirBodySmall.copyWith(color: kContentMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Column(
      children: [
        // Video preview
        if (_videoController != null && _videoController!.value.isInitialized)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(kSpaceMD),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kRadiusLG),
                border: Border.all(color: kBorderLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusLG),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          ),
        
        // Loading indicator
        Expanded(
          flex: 3,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: kContentHigh,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: kSpaceLG),
                Text(
                  'AI анализирует технику...',
                  style: kNoirTitleMedium.copyWith(color: kContentHigh),
                ),
                const SizedBox(height: kSpaceSM),
                Text(
                  'Извлечение ключевых кадров и анализ',
                  style: kNoirBodyMedium.copyWith(color: kContentMedium),
                ),
                const SizedBox(height: kSpaceLG),
                _buildLoadingSteps(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSteps() {
    return Column(
      children: [
        _buildStep('Извлечение кадров', true),
        _buildStep('Анализ позиции тела', true),
        _buildStep('Сравнение с эталоном', false),
        _buildStep('Формирование рекомендаций', false),
      ],
    );
  }

  Widget _buildStep(String text, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpaceXS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? kContentHigh : kContentLow,
            size: 16,
          ),
          const SizedBox(width: kSpaceSM),
          Text(
            text,
            style: kNoirBodySmall.copyWith(
              color: completed ? kContentMedium : kContentLow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
            const SizedBox(height: kSpaceMD),
            Text(
              'Ошибка анализа',
              style: kNoirTitleMedium.copyWith(color: kContentHigh),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              _error ?? 'Неизвестная ошибка',
              style: kNoirBodyMedium.copyWith(color: kContentMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpaceLG),
            NoirPrimaryButton(
              onPressed: () {
                setState(() {
                  _isAnalyzing = true;
                  _error = null;
                });
                _analyzeForm();
              },
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsState(AppLocalizations l10n) {
    if (_result == null) return const SizedBox();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall score
          _buildScoreCard(),
          
          const SizedBox(height: kSpaceLG),
          
          // Errors detected
          if (_result!.errors.isNotEmpty) ...[
            _buildSectionTitle('Обнаруженные ошибки', Icons.warning_amber_rounded, Colors.orange),
            const SizedBox(height: kSpaceSM),
            _buildErrorsList(),
            const SizedBox(height: kSpaceLG),
          ],
          
          // Corrections
          if (_result!.corrections.isNotEmpty) ...[
            _buildSectionTitle('Рекомендации', Icons.lightbulb_outline, Colors.green),
            const SizedBox(height: kSpaceSM),
            _buildCorrectionsList(),
            const SizedBox(height: kSpaceLG),
          ],
          
          // YouTube guide button
          _buildYouTubeButton(),
          
          const SizedBox(height: kSpaceLG),
          
          // Done button
          SizedBox(
            width: double.infinity,
            child: NoirPrimaryButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Готово'),
            ),
          ),
          
          const SizedBox(height: kSpaceLG),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = _result!.overallScore;
    final scoreColor = score >= 80 
        ? Colors.green 
        : score >= 60 
            ? Colors.orange 
            : Colors.red;
    
    return NoirGlassContainer(
      padding: const EdgeInsets.all(kSpaceLG),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: kNoirDisplaySmall.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/100',
                    style: kNoirBodySmall.copyWith(color: kContentMedium),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: kSpaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getScoreLabel(score),
                  style: kNoirTitleMedium.copyWith(color: scoreColor),
                ),
                const SizedBox(height: kSpaceXS),
                Text(
                  _result!.summary,
                  style: kNoirBodySmall.copyWith(color: kContentMedium),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Отличная техника!';
    if (score >= 80) return 'Хорошая техника';
    if (score >= 60) return 'Есть над чем работать';
    if (score >= 40) return 'Требуется улучшение';
    return 'Нужна коррекция';
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: kSpaceSM),
        Text(
          title,
          style: kNoirTitleSmall.copyWith(color: kContentHigh),
        ),
      ],
    );
  }

  Widget _buildErrorsList() {
    return NoirGlassContainer(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        children: _result!.errors.map((error) => Padding(
          padding: const EdgeInsets.symmetric(vertical: kSpaceXS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: kSpaceSM),
              Expanded(
                child: Text(
                  error,
                  style: kNoirBodyMedium.copyWith(color: kContentHigh),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCorrectionsList() {
    return NoirGlassContainer(
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        children: _result!.corrections.map((correction) => Padding(
          padding: const EdgeInsets.symmetric(vertical: kSpaceXS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade400,
                size: 18,
              ),
              const SizedBox(width: kSpaceSM),
              Expanded(
                child: Text(
                  correction,
                  style: kNoirBodyMedium.copyWith(
                    color: Colors.green.shade300,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildYouTubeButton() {
    return GestureDetector(
      onTap: _openYouTubeGuide,
      child: NoirGlassContainer(
        padding: const EdgeInsets.all(kSpaceMD),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(kRadiusMD),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: kSpaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Видеоурок на YouTube',
                    style: kNoirTitleSmall.copyWith(color: kContentHigh),
                  ),
                  Text(
                    'Посмотрите правильную технику выполнения',
                    style: kNoirBodySmall.copyWith(color: kContentMedium),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              color: kContentMedium,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
