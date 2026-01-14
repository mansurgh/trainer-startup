import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../theme/app_theme.dart';
import '../theme/noir_theme.dart' as noir;
import '../theme/noir_theme.dart';
import '../widgets/noir_glass_components.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/noir_toast_service.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../state/user_state.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dataSharingEnabled = false;
  bool _analyticsEnabled = true;
  bool _isChangingLocale = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getSettings();
    setState(() {
      _notificationsEnabled = settings['notifications_enabled'] ?? true;
      _dataSharingEnabled = settings['data_sharing_enabled'] ?? false;
      _analyticsEnabled = settings['analytics_enabled'] ?? true;
    });
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings({
      'notifications_enabled': _notificationsEnabled,
      'data_sharing_enabled': _dataSharingEnabled,
      'analytics_enabled': _analyticsEnabled,
    });
  }

  Future<void> _changeLocale(String languageCode) async {
    setState(() => _isChangingLocale = true);
    
    try {
      final locale = languageCode == 'ru' ? AppLocales.russian : AppLocales.english;
      await ref.read(localeStateProvider.notifier).setLocale(locale);
      
      // Wait a moment for UI to rebuild
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        NoirToast.success(context, l10n.languageChanged);
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, 'Error changing language');
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingLocale = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final selectedLanguage = currentLocale.languageCode;
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kOledBlack,
          appBar: AppBar(
            title: Text(l10n.settings, style: kDenseSubheading),
            backgroundColor: kObsidianSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: kTextPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Основные настройки
                _buildSection(
                  title: l10n.notifications,
                  icon: Icons.notifications_outlined,
                  children: [
                    _buildSwitchTile(
                      title: l10n.pushNotifications,
                      subtitle: l10n.workoutReminders,
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        setState(() => _notificationsEnabled = value);
                        await _saveSettings();
                        if (value) {
                          await NotificationService.requestPermissions();
                          await NotificationService.setupDefaultReminders();
                        } else {
                          await NotificationService.cancelAllNotifications();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Язык приложения
                _buildSection(
                  title: l10n.language,
                  icon: Icons.language_outlined,
                  children: [
                    _buildDropdownTile(
                      title: l10n.interfaceLanguage,
                      subtitle: _getLanguageName(selectedLanguage),
                      icon: Icons.translate,
                      value: selectedLanguage,
                      items: const [
                        DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
                        DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                      ],
                      onChanged: (value) {
                        if (value != null && value != selectedLanguage) {
                          HapticFeedback.lightImpact();
                          _changeLocale(value);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // О приложении
                _buildSection(
                  title: l10n.aboutApp,
                  icon: Icons.info_outlined,
                  children: [
                    _buildListTile(
                      title: l10n.version,
                      subtitle: '1.0.0',
                      icon: Icons.info,
                    ),
                    _buildListTile(
                      title: l10n.privacyPolicy,
                      subtitle: l10n.howWeUseYourData,
                      icon: Icons.policy,
                      onTap: () => _showPrivacyPolicy(),
                    ),
                    _buildListTile(
                      title: l10n.termsOfService,
                      subtitle: l10n.appUsageRules,
                      icon: Icons.description,
                      onTap: () => _showTermsOfService(),
                    ),
                    _buildListTile(
                      title: l10n.support,
                      subtitle: l10n.contactUs,
                      icon: Icons.support_agent,
                      onTap: () => _showSupport(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Кнопка выхода
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kErrorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kErrorRed.withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showLogoutDialog(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: kErrorRed),
                            const SizedBox(width: 8),
                            Text(l10n.logout, style: kBodyText.copyWith(color: kErrorRed, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
        ),
        
        // Loading overlay for locale change
        if (_isChangingLocale)
          _NoirGlassLoadingOverlay(message: l10n.loading),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kObsidianSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kObsidianBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: kElectricAmberStart, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: kDenseSubheading.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: kBodyText.copyWith(color: kTextPrimary)),
      subtitle: Text(subtitle, style: kCaptionText.copyWith(color: kTextTertiary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: kElectricAmberStart,
        activeTrackColor: kElectricAmberStart.withOpacity(0.3),
        inactiveThumbColor: kTextTertiary,
        inactiveTrackColor: kObsidianBorder,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: kTextSecondary),
      title: Text(title, style: kBodyText.copyWith(color: kTextPrimary)),
      subtitle: Text(subtitle, style: kCaptionText.copyWith(color: kTextTertiary)),
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: kTextTertiary) : null,
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: kTextSecondary),
      title: Text(title, style: kBodyText.copyWith(color: kTextPrimary)),
      subtitle: Text(subtitle, style: kCaptionText.copyWith(color: kElectricAmberStart)),
      trailing: PopupMenuButton<T>(
        icon: const Icon(Icons.chevron_right, color: kTextTertiary),
        color: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: onChanged,
        itemBuilder: (context) => items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: item.child,
          );
        }).toList(),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru': return 'Русский';
      case 'en': return 'English';
      default: return 'Русский';
    }
  }

  void _showNotificationSettings() {
    NoirGlassDialog.showAlert(
      context,
      title: 'Настройки уведомлений',
      content: 'Здесь можно настроить время и типы уведомлений.',
      icon: Icons.notifications_rounded,
      confirmText: 'Закрыть',
    );
  }

  void _showLanguageDialog() {
    final currentLocale = ref.read(localeProvider);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: 'Выберите язык',
        icon: Icons.language_rounded,
        contentWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              ctx,
              'Русский',
              'ru',
              currentLocale.languageCode == 'ru',
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              ctx,
              'English',
              'en',
              currentLocale.languageCode == 'en',
            ),
          ],
        ),
        confirmText: 'Закрыть',
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }
  
  Widget _buildLanguageOption(BuildContext ctx, String label, String code, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        _changeLocale(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? noir.kContentHigh.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(noir.kRadiusMD),
          border: Border.all(
            color: isSelected ? noir.kContentHigh : noir.kNoirSteel.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? noir.kContentHigh : noir.kContentMedium,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: noir.kNoirBodyMedium.copyWith(
                color: isSelected ? noir.kContentHigh : noir.kContentMedium,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    NoirToast.info(context, 'Экспорт данных в разработке...');
  }

  void _showDeleteDataDialog() async {
    final confirmed = await NoirGlassDialog.showConfirmation(
      context,
      title: 'Удалить все данные?',
      content: 'Это действие нельзя отменить. Все ваши данные будут удалены.',
      icon: Icons.warning_rounded,
      confirmText: 'Удалить',
      cancelText: 'Отмена',
      isDestructive: true,
    );
    
    if (confirmed == true) {
      await ref.read(userProvider.notifier).clearUser();
      if (mounted) {
        Navigator.pop(context);
        NoirToast.error(context, 'Все данные удалены');
      }
    }
  }

  void _showPrivacyPolicy() {
    NoirGlassDialog.showAlert(
      context,
      title: 'Политика конфиденциальности',
      content: 'Мы серьезно относимся к защите ваших данных. Все ваши личные данные хранятся локально на вашем устройстве и не передаются третьим лицам без вашего согласия.',
      icon: Icons.privacy_tip_rounded,
      confirmText: 'Закрыть',
    );
  }

  void _showTermsOfService() {
    NoirGlassDialog.showAlert(
      context,
      title: 'Условия использования',
      content: 'Используя приложение PulseFit Pro, вы соглашаетесь с нашими условиями использования. Приложение предназначено для информационных целей и не заменяет консультацию с врачом.',
      icon: Icons.description_rounded,
      confirmText: 'Закрыть',
    );
  }

  void _showSupport() {
    NoirGlassDialog.showAlert(
      context,
      title: 'Поддержка',
      content: 'Если у вас есть вопросы или проблемы, свяжитесь с нами:\n\n✉️ support@pulsefit.pro\n📱 @pulsefit_support',
      icon: Icons.support_agent_rounded,
      confirmText: 'Закрыть',
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => _NoirGlassDialog(
        title: 'Выйти из аккаунта?',
        content: 'Вы будете перенаправлены на экран входа.',
        icon: Icons.logout_rounded,
        cancelText: 'Отмена',
        confirmText: 'Выйти',
        isDestructive: true,
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () {
          // INSTANTLY navigate before async signOut to prevent waiting for sheet close
          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
          
          // Fire-and-forget: async cleanup in background
          ref.read(authProvider.notifier).signOut().catchError((e) {
            debugPrint('[Settings] Logout cleanup error: $e');
          });
        },
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => _NoirGlassDialog(
        title: 'Обратная связь',
        content: 'Для обратной связи напишите нам на:\nsupport@pulsefit.pro',
        icon: Icons.feedback_outlined,
        confirmText: 'OK',
        onConfirm: () => Navigator.pop(dialogContext),
      ),
    );
  }
}

// =============================================================================
// Noir Glass Loading Overlay
// =============================================================================

class _NoirGlassLoadingOverlay extends StatelessWidget {
  const _NoirGlassLoadingOverlay({required this.message});
  
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: noir.kNoirGraphite.withOpacity(0.8),
              borderRadius: BorderRadius.circular(noir.kRadiusLG),
              border: Border.all(color: noir.kNoirSteel.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(noir.kContentHigh),
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: noir.kNoirBodyMedium.copyWith(color: noir.kContentHigh),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// =============================================================================
// NOIR GLASS DIALOG — Monochrome Alert Dialog
// =============================================================================

class _NoirGlassDialog extends StatelessWidget {
  const _NoirGlassDialog({
    required this.title,
    required this.content,
    this.icon,
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.isDestructive = false,
  });

  final String title;
  final String content;
  final IconData? icon;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    // FIXED: Wrap in Material to prevent yellow underline on Text widgets
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(noir.kRadiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(noir.kSpaceLG),
              decoration: BoxDecoration(
                color: noir.kNoirGraphite.withOpacity(0.95),
                borderRadius: BorderRadius.circular(noir.kRadiusXL),
                border: Border.all(color: noir.kNoirSteel.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon and title
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDestructive 
                              ? const Color(0xFFF87171).withOpacity(0.15)
                              : noir.kContentHigh.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: isDestructive 
                              ? const Color(0xFFF87171)
                              : noir.kContentHigh,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: noir.kSpaceMD),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: noir.kNoirTitleMedium.copyWith(
                            color: noir.kContentHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: noir.kSpaceMD),
                  
                  // Content
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      content,
                      style: noir.kNoirBodyMedium.copyWith(
                        color: noir.kContentMedium,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: noir.kSpaceLG),
                  
                  // Buttons
                  Row(
                    children: [
                      if (cancelText != null) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: onCancel,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(noir.kRadiusMD),
                                border: Border.all(color: noir.kBorderMedium),
                              ),
                              child: Center(
                                child: Text(
                                  cancelText!,
                                  style: noir.kNoirBodyMedium.copyWith(
                                    color: noir.kContentMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: noir.kSpaceMD),
                      ],
                      if (confirmText != null)
                        Expanded(
                          child: GestureDetector(
                            onTap: onConfirm,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDestructive 
                                  ? const Color(0xFFF87171)
                                  : noir.kContentHigh,
                                borderRadius: BorderRadius.circular(noir.kRadiusMD),
                              ),
                              child: Center(
                                child: Text(
                                  confirmText!,
                                  style: noir.kNoirBodyMedium.copyWith(
                                    color: noir.kNoirBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}