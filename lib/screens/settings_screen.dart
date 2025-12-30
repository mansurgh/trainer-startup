import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../core/theme.dart';
import '../theme/app_theme.dart';
import '../state/user_state.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../config/supabase_config.dart';

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
      _selectedLanguage = settings['language'] ?? 'ru';
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
    return Scaffold(
      backgroundColor: kOledBlack,
      appBar: AppBar(
        title: Text('Настройки', style: kDenseSubheading),
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
              title: 'Уведомления',
              icon: Icons.notifications_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Push-уведомления',
                  subtitle: 'Напоминания о тренировках',
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
              title: 'Язык',
              icon: Icons.language_outlined,
              children: [
                _buildDropdownTile(
                  title: 'Язык интерфейса',
                  subtitle: _getLanguageName(_selectedLanguage),
                  icon: Icons.translate,
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
                    DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => _selectedLanguage = value);
                      await _saveSettings();
                      // Показываем уведомление
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Язык изменён на ${_getLanguageName(value)}. Перезапустите приложение для применения изменений.'),
                            backgroundColor: kSuccessGreen,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // О приложении
            _buildSection(
              title: 'О приложении',
              icon: Icons.info_outlined,
              children: [
                _buildListTile(
                  title: 'Версия',
                  subtitle: '1.0.0',
                  icon: Icons.info,
                ),
                _buildListTile(
                  title: 'Политика конфиденциальности',
                  subtitle: 'Как мы используем ваши данные',
                  icon: Icons.policy,
                  onTap: () => _showPrivacyPolicy(),
                ),
                _buildListTile(
                  title: 'Условия использования',
                  subtitle: 'Правила использования приложения',
                  icon: Icons.description,
                  onTap: () => _showTermsOfService(),
                ),
                _buildListTile(
                  title: 'Поддержка',
                  subtitle: 'Связаться с нами',
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
                        Text('Выйти из аккаунта', style: kBodyText.copyWith(color: kErrorRed, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Настройки уведомлений', style: kDenseSubheading),
        content: Text('Здесь можно настроить время и типы уведомлений.', style: kBodyText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: kElectricAmberStart)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Выберите язык', style: kDenseSubheading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Русский', style: kBodyText.copyWith(color: kTextPrimary)),
              value: 'ru',
              groupValue: _selectedLanguage,
              activeColor: kElectricAmberStart,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('English', style: kBodyText.copyWith(color: kTextPrimary)),
              value: 'en',
              groupValue: _selectedLanguage,
              activeColor: kElectricAmberStart,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Экспорт данных в разработке...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: kErrorRed, size: 28),
            const SizedBox(width: 12),
            Text('Удалить все данные?', style: kDenseSubheading),
          ],
        ),
        content: Text(
          'Это действие нельзя отменить. Все ваши данные будут удалены.',
          style: kBodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: kTextSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(userProvider.notifier).clearUser();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все данные удалены'),
                  backgroundColor: kErrorRed,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: kErrorRed),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Политика конфиденциальности', style: kDenseSubheading),
        content: Text(
          'Мы серьезно относимся к защите ваших данных. Все ваши личные данные хранятся локально на вашем устройстве и не передаются третьим лицам без вашего согласия.',
          style: kBodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: kElectricAmberStart)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Условия использования', style: kDenseSubheading),
        content: Text(
          'Используя приложение PulseFit Pro, вы соглашаетесь с нашими условиями использования. Приложение предназначено для информационных целей и не заменяет консультацию с врачом.',
          style: kBodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: kElectricAmberStart)),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Поддержка', style: kDenseSubheading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Если у вас есть вопросы или проблемы, свяжитесь с нами:', style: kBodyText),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: kElectricAmberStart, size: 18),
                const SizedBox(width: 8),
                Text('support@pulsefit.pro', style: kBodyText.copyWith(color: kTextPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.telegram, color: kElectricAmberStart, size: 18),
                const SizedBox(width: 8),
                Text('@pulsefit_support', style: kBodyText.copyWith(color: kTextPrimary)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: kElectricAmberStart)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: kErrorRed, size: 28),
            const SizedBox(width: 12),
            Text('Выйти из аккаунта?', style: kDenseSubheading),
          ],
        ),
        content: Text(
          'Вы будете перенаправлены на экран входа.',
          style: kBodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: kTextSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              // Закрываем диалог
              Navigator.pop(context);
              
              try {
                // Выход из Supabase
                await SupabaseConfig.client.auth.signOut();
                // Очистить локальные данные
                await ref.read(userProvider.notifier).clearUser();
                
                // Навигация на экран логина
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint('[Settings] Logout error: $e');
                // Даже если ошибка, всё равно выходим локально
                await ref.read(userProvider.notifier).clearUser();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: kErrorRed),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kObsidianSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.feedback_outlined, color: kElectricAmberStart, size: 28),
            const SizedBox(width: 12),
            Text('Обратная связь', style: kDenseSubheading),
          ],
        ),
        content: Text(
          'Для обратной связи напишите нам на:\nsupport@pulsefit.pro',
          style: kBodyText,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: kElectricAmberStart),
            child: const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
