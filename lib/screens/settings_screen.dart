import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme.dart';
import '../config/supabase_config.dart';
import '../state/user_state.dart';
import '../state/activity_state.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../providers/locale_provider.dart';
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
  String _selectedLanguage = 'ru';

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
      // Default to 'en' if not set, matching LocaleProvider
      _selectedLanguage = settings['language'] ?? 'en';
    });
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings({
      'notifications_enabled': _notificationsEnabled,
      'data_sharing_enabled': _dataSharingEnabled,
      'analytics_enabled': _analyticsEnabled,
      'language': _selectedLanguage,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Основные настройки
            _buildSection(
              title: l10n.notificationsSection,
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

            // О приложении
            _buildSection(
              title: l10n.aboutSection,
              icon: Icons.info_outlined,
              children: [
                _buildListTile(
                  title: l10n.version,
                  subtitle: '1.0.0',
                  icon: Icons.info,
                ),
                _buildListTile(
                  title: l10n.privacyPolicy,
                  subtitle: l10n.privacyPolicySubtitle,
                  icon: Icons.policy,
                  onTap: () => _showPrivacyPolicy(),
                ),
                _buildListTile(
                  title: l10n.termsOfService,
                  subtitle: l10n.termsOfServiceSubtitle,
                  icon: Icons.description,
                  onTap: () => _showTermsOfService(),
                ),
                _buildListTile(
                  title: l10n.support,
                  subtitle: l10n.supportSubtitle,
                  icon: Icons.support_agent,
                  onTap: () => _showSupport(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Язык
            _buildSection(
              title: l10n.languageAndRegion,
              icon: Icons.language,
              children: [
                _buildListTile(
                  title: l10n.languageSetting,
                  subtitle: _selectedLanguage == 'ru' ? l10n.russian : l10n.english,
                  icon: Icons.translate,
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Кнопка выхода
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logoutButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
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
      leading: Icon(icon, size: 20),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: Text(l10n.russian),
                value: 'ru',
                groupValue: _selectedLanguage,
                onChanged: (value) async {
                  await ref.read(localeProvider.notifier).setLocale(Locale(value!));
                  setState(() => _selectedLanguage = value);
                  await _saveSettings();
                  if (mounted) {
                    Navigator.pop(context);
                    // Перезагружаем весь экран
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.english),
                value: 'en',
                groupValue: _selectedLanguage,
                onChanged: (value) async {
                  await ref.read(localeProvider.notifier).setLocale(Locale(value!));
                  setState(() => _selectedLanguage = value);
                  await _saveSettings();
                  if (mounted) {
                    Navigator.pop(context);
                    // Перезагружаем весь экран
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.privacyPolicyTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.privacyPolicyContent,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Условия использования',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Используя приложение PulseFit Pro, вы соглашаетесь с нашими условиями использования. Приложение предназначено для информационных целей и не заменяет консультацию с врачом.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.deleteDataWarning,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deleteDataDescription,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.clearData)),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(l10n.deleteButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupport() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.supportTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.supportDescription,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text('Email: support@pulsefit.pro'),
              const Text('Telegram: @pulsefit_support'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Выйти из аккаунта?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Вы будете перенаправлены на экран входа.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          print('[Settings] Starting sign out...');
                          
                          // Получаем userId перед выходом
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('user_id');
                          
                          // Выходим из Supabase с полной очисткой сессии
                          await SupabaseConfig.client.auth.signOut(scope: SignOutScope.global);
                          print('[Settings] Supabase sign out successful - session cleared');
                          
                          // Очищаем только данные текущего пользователя
                          if (userId != null) {
                            final keys = prefs.getKeys();
                            for (final key in keys) {
                              if (key.contains('_${userId}_') || key.contains('_$userId') || key == 'user_id') {
                                await prefs.remove(key);
                                print('[Settings] Removed key: $key');
                              }
                            }
                          }
                          
                          // Invalidate Riverpod state to prevent stale data
                          ref.invalidate(userProvider);
                          ref.invalidate(activityDataProvider);
                          ref.invalidate(todaysWinProvider);
                          ref.invalidate(consistencyStreakProvider);
                          
                          print('[Settings] User data cleared, navigating to login screen...');
                          
                          // Навигация к LoginScreen через root navigator
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          print('[Settings] Sign out error: $e');
                          
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ошибка выхода: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Выйти'),
                    ),
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
