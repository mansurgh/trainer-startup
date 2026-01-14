// =============================================================================
// form_check_camera_screen.dart — AI Form Check Camera
// =============================================================================
// Full-screen camera with:
// - Front/Back camera switch
// - Timer selection (3s, 5s, 10s countdown)
// - 15s max recording with auto-stop
// - Noir Glass UI overlays
// =============================================================================

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/noir_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/noir_glass_components.dart';
import '../services/noir_toast_service.dart' show NoirToast;
import 'form_feedback_screen.dart';

class FormCheckCameraScreen extends StatefulWidget {
  const FormCheckCameraScreen({
    super.key,
    required this.exerciseName,
    this.exerciseId,
  });

  final String exerciseName;
  final String? exerciseId;

  @override
  State<FormCheckCameraScreen> createState() => _FormCheckCameraScreenState();
}

class _FormCheckCameraScreenState extends State<FormCheckCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isFrontCamera = true;
  bool _isRecording = false;
  bool _isProcessing = false;
  
  // Timer settings
  int _selectedCountdown = 3; // 3, 5, or 10 seconds
  int _currentCountdown = 0;
  bool _isCountingDown = false;
  
  // Recording timer
  int _recordingSeconds = 0;
  static const int _maxRecordingSeconds = 15;
  Timer? _countdownTimer;
  Timer? _recordingTimer;
  
  // Video file path
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Request permissions
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      if (mounted) {
        NoirToast.error(context, 'Требуется разрешение на камеру и микрофон');
        Navigator.pop(context);
      }
      return;
    }
    
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          NoirToast.error(context, 'Камера не найдена');
          Navigator.pop(context);
        }
        return;
      }
      
      // Find front camera by default (for form check)
      final frontCamera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      
      await _setupCamera(frontCamera);
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, 'Ошибка инициализации камеры');
      }
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isFrontCamera = camera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, 'Ошибка камеры: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    
    HapticFeedback.lightImpact();
    
    final newCamera = _cameras.firstWhere(
      (c) => c.lensDirection != (_isFrontCamera 
          ? CameraLensDirection.front 
          : CameraLensDirection.back),
      orElse: () => _cameras.first,
    );
    
    await _setupCamera(newCamera);
  }

  void _selectCountdown(int seconds) {
    if (_isRecording || _isCountingDown) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedCountdown = seconds);
  }

  void _startCountdown() {
    if (_isCountingDown || _isRecording) return;
    
    // Desktop fallback: video recording often fails on Windows/Linux/macOS
    final bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    HapticFeedback.mediumImpact();
    setState(() {
      _isCountingDown = true;
      _currentCountdown = _selectedCountdown;
    });
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCountdown > 1) {
        HapticFeedback.lightImpact();
        setState(() => _currentCountdown--);
      } else {
        timer.cancel();
        // On desktop, skip to feedback immediately
        if (isDesktop) {
          _handleDesktopFallback();
        } else {
          _startRecording();
        }
      }
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    // Desktop fallback: video recording often fails on Windows/Linux/macOS
    final bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    try {
      // Get temp directory for video
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _videoPath = '${tempDir.path}/form_check_$timestamp.mp4';
      
      // Try to start recording - may fail on desktop
      if (isDesktop) {
        // On desktop, skip actual recording and go straight to feedback with mock
        _handleDesktopFallback();
        return;
      }
      
      await _controller!.startVideoRecording();
      
      HapticFeedback.heavyImpact();
      setState(() {
        _isCountingDown = false;
        _isRecording = true;
        _recordingSeconds = 0;
      });
      
      // Start recording timer with auto-stop at 15s
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_recordingSeconds >= _maxRecordingSeconds - 1) {
          timer.cancel();
          _stopRecording();
        } else {
          setState(() => _recordingSeconds++);
        }
      });
    } catch (e) {
      // Recording failed - use desktop fallback
      if (isDesktop) {
        _handleDesktopFallback();
      } else {
        setState(() {
          _isCountingDown = false;
          _isRecording = false;
        });
        if (mounted) {
          NoirToast.error(context, 'Ошибка записи');
        }
      }
    }
  }
  
  /// Desktop fallback: Skip video recording and go to feedback with mock data
  void _handleDesktopFallback() {
    setState(() {
      _isCountingDown = false;
      _isRecording = false;
      _isProcessing = true;
    });
    
    if (mounted) {
      NoirToast.info(context, 'Видеозапись недоступна на Desktop. Симуляция...');
    }
    
    // Navigate to feedback screen with null video (will use mock)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FormFeedbackScreen(
              videoPath: null, // Pass null to trigger mock mode
              exerciseName: widget.exerciseName,
            ),
          ),
        );
      }
    });
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;
    
    _recordingTimer?.cancel();
    
    try {
      final videoFile = await _controller!.stopVideoRecording();
      
      // Copy to our path if needed
      if (_videoPath != null) {
        await videoFile.saveTo(_videoPath!);
      } else {
        _videoPath = videoFile.path;
      }
      
      HapticFeedback.heavyImpact();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      
      // Navigate to feedback screen with video
      if (mounted && _videoPath != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FormFeedbackScreen(
              videoPath: _videoPath!,
              exerciseName: widget.exerciseName,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      if (mounted) {
        NoirToast.error(context, 'Ошибка сохранения видео');
      }
    }
  }

  void _cancelRecording() async {
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    
    if (_isRecording && _controller != null) {
      try {
        await _controller!.stopVideoRecording();
      } catch (_) {}
    }
    
    setState(() {
      _isCountingDown = false;
      _isRecording = false;
      _currentCountdown = 0;
      _recordingSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16, // Portrait video
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: kContentHigh),
            ),
          
          // Top bar with close and switch camera
          _buildTopBar(l10n),
          
          // Countdown overlay
          if (_isCountingDown) _buildCountdownOverlay(),
          
          // Recording indicator
          if (_isRecording) _buildRecordingIndicator(),
          
          // Processing overlay
          if (_isProcessing) _buildProcessingOverlay(l10n),
          
          // Bottom controls
          if (!_isProcessing) _buildBottomControls(l10n),
        ],
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSpaceMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              _buildGlassButton(
                icon: Icons.close_rounded,
                onTap: () {
                  _cancelRecording();
                  Navigator.pop(context);
                },
              ),
              
              // Exercise name
              Expanded(
                child: Text(
                  widget.exerciseName,
                  textAlign: TextAlign.center,
                  style: kNoirTitleMedium.copyWith(color: kContentHigh),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Switch camera
              _buildGlassButton(
                icon: Icons.cameraswitch_rounded,
                onTap: _switchCamera,
                enabled: !_isRecording && _cameras.length > 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: kNoirCarbon.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: kBorderLight),
        ),
        child: Icon(
          icon,
          color: enabled ? kContentHigh : kContentLow,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: kNoirBlack.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_currentCountdown',
              style: kNoirDisplayLarge.copyWith(
                color: kContentHigh,
                fontSize: 120,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: kSpaceMD),
            Text(
              l10n.getReady,
              style: kNoirTitleLarge.copyWith(color: kContentMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(kRadiusLG),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: kContentHigh,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: kSpaceSM),
              Text(
                'REC ${_recordingSeconds}s / ${_maxRecordingSeconds}s',
                style: kNoirBodyMedium.copyWith(
                  color: kContentHigh,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay(AppLocalizations l10n) {
    return Container(
      color: kNoirBlack.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kContentHigh),
            const SizedBox(height: kSpaceLG),
            Text(
              '${l10n.processing}...',
              style: kNoirTitleMedium.copyWith(color: kContentHigh),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              l10n.aiAnalyzingForm,
              style: kNoirBodyMedium.copyWith(color: kContentMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSpaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer selection (only when not recording)
              if (!_isRecording && !_isCountingDown) ...[
                Text(
                  l10n.countdownTimer,
                  style: kNoirBodyMedium.copyWith(color: kContentMedium),
                ),
                const SizedBox(height: kSpaceSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [3, 5, 10].map((seconds) {
                    final isSelected = _selectedCountdown == seconds;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpaceXS),
                      child: GestureDetector(
                        onTap: () => _selectCountdown(seconds),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpaceMD,
                            vertical: kSpaceSM,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? kContentHigh 
                                : kNoirCarbon.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(kRadiusMD),
                            border: Border.all(
                              color: isSelected ? kContentHigh : kBorderLight,
                            ),
                          ),
                          child: Text(
                            '${seconds}s',
                            style: kNoirBodyMedium.copyWith(
                              color: isSelected ? kNoirBlack : kContentHigh,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: kSpaceLG),
              ],
              
              // Main record button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRecording) ...[
                    // Cancel button
                    _buildGlassButton(
                      icon: Icons.close_rounded,
                      onTap: _cancelRecording,
                    ),
                    const SizedBox(width: kSpaceLG),
                  ],
                  
                  // Record/Stop button
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startCountdown,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : Colors.transparent,
                        border: Border.all(
                          color: kContentHigh,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 24 : 56,
                          height: _isRecording ? 24 : 56,
                          decoration: BoxDecoration(
                            color: _isRecording ? kContentHigh : Colors.red,
                            borderRadius: BorderRadius.circular(
                              _isRecording ? kRadiusSM : 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: kSpaceMD),
              
              // Instructions
              Text(
                _isRecording 
                    ? l10n.tapToStopOrWait(_maxRecordingSeconds.toString())
                    : l10n.tapToStartRecording,
                style: kNoirBodySmall.copyWith(color: kContentLow),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
