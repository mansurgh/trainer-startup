import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme.dart';
import '../state/user_state.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

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
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Настройки'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Уведомления
            _buildSection(
              title: 'Уведомления',
              icon: Icons.notifications_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Push-уведомления',
                  subtitle: 'Напоминания о тренировках и питании',
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
                _buildListTile(
                  title: 'Управление уведомлениями',
                  subtitle: 'Настроить время и типы уведомлений',
                  icon: Icons.schedule,
                  onTap: () => _showNotificationSettings(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Приватность и данные
            _buildSection(
              title: 'Приватность и данные',
              icon: Icons.privacy_tip_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Аналитика использования',
                  subtitle: 'Помочь улучшить приложение',
                  value: _analyticsEnabled,
                  onChanged: (value) async {
                    setState(() => _analyticsEnabled = value);
                    await _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'Обмен данными',
                  subtitle: 'Анонимная статистика для исследований',
                  value: _dataSharingEnabled,
                  onChanged: (value) async {
                    setState(() => _dataSharingEnabled = value);
                    await _saveSettings();
                  },
                ),
                _buildListTile(
                  title: 'Экспорт данных',
                  subtitle: 'Скачать все ваши данные',
                  icon: Icons.download,
                  onTap: () => _exportData(),
                ),
                _buildListTile(
                  title: 'Удалить все данные',
                  subtitle: 'Очистить все данные приложения',
                  icon: Icons.delete_forever,
                  onTap: () => _showDeleteDataDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Язык и регион
            _buildSection(
              title: 'Язык и регион',
              icon: Icons.language_outlined,
              children: [
                _buildListTile(
                  title: 'Язык',
                  subtitle: _selectedLanguage == 'ru' ? 'Русский' : 'English',
                  icon: Icons.translate,
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Разрешения
            _buildSection(
              title: 'Разрешения',
              icon: Icons.security_outlined,
              children: [
                _buildListTile(
                  title: 'Камера',
                  subtitle: 'Для фото прогресса и анализа еды',
                  icon: Icons.camera_alt,
                  onTap: () => _requestPermission(Permission.camera),
                ),
                _buildListTile(
                  title: 'Галерея',
                  subtitle: 'Для выбора изображений',
                  icon: Icons.photo_library,
                  onTap: () => _requestPermission(Permission.photos),
                ),
                _buildListTile(
                  title: 'Уведомления',
                  subtitle: 'Для напоминаний о тренировках',
                  icon: Icons.notifications,
                  onTap: () => _requestPermission(Permission.notification),
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: const Text('Выйти из аккаунта'),
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

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Настройки уведомлений',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text('Здесь можно настроить время и типы уведомлений.'),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите язык',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('Русский'),
                value: 'ru',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
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
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Удалить все данные?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Это действие нельзя отменить. Все ваши данные будут удалены.',
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
                        await ref.read(userProvider.notifier).clearUser();
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Все данные удалены'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Удалить'),
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

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Политика конфиденциальности',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Мы серьезно относимся к защите ваших данных. Все ваши личные данные хранятся локально на вашем устройстве и не передаются третьим лицам без вашего согласия.',
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

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Поддержка',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Если у вас есть вопросы или проблемы, свяжитесь с нами:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text('Email: support@pulsefit.pro'),
              const Text('Telegram: @pulsefit_support'),
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
                        await ref.read(userProvider.notifier).clearUser();
                        Navigator.pop(context);
                        Navigator.pop(context);
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

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status.isGranted 
              ? 'Разрешение предоставлено' 
              : 'Разрешение отклонено',
        ),
        backgroundColor: status.isGranted ? Colors.green : Colors.red,
      ),
    );
  }
}
