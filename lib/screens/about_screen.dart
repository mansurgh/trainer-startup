import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../widgets/noir_glass_components.dart';
import '../theme/noir_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('О приложении'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Логотип и основная информация
            GlassCard(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Trainer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Версия 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ваш персональный AI-тренер для достижения фитнес-целей',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Основные функции
            _buildSection(
              context: context,
              title: 'Основные функции',
              icon: Icons.star_outline,
              children: [
                _buildFeatureItem(
                  icon: Icons.camera_alt,
                  title: 'Анализ техники упражнений',
                  description: 'AI следит за правильностью выполнения движений',
                ),
                _buildFeatureItem(
                  icon: Icons.restaurant,
                  title: 'Рацион по фото холодильника',
                  description: 'AI анализирует продукты и предлагает питание',
                ),
                _buildFeatureItem(
                  icon: Icons.chat,
                  title: 'Чат с тренером',
                  description: 'Мгновенные советы и поддержка 24/7',
                ),
                _buildFeatureItem(
                  icon: Icons.trending_up,
                  title: 'Адаптивные программы',
                  description: 'Тренировки подстраиваются под ваш прогресс',
                ),
                _buildFeatureItem(
                  icon: Icons.all_inclusive,
                  title: 'Все в одном приложении',
                  description: 'Тренировки, питание и поддержка в одном месте',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Контакты и поддержка
            _buildSection(
              context: context,
              title: 'Поддержка',
              icon: Icons.support_agent,
              children: [
                _buildContactItem(
                  icon: Icons.email,
                  title: 'Email поддержка',
                  subtitle: 'support@pulsefit.pro',
                  onTap: () => _launchEmail('support@pulsefit.pro'),
                ),
                _buildContactItem(
                  icon: Icons.telegram,
                  title: 'Telegram',
                  subtitle: '@pulsefit_support',
                  onTap: () => _launchTelegram('@pulsefit_support'),
                ),
                _buildContactItem(
                  icon: Icons.bug_report,
                  title: 'Сообщить об ошибке',
                  subtitle: 'Помогите нам улучшить приложение',
                  onTap: () => _launchEmail('bugs@pulsefit.pro'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Правовая информация
            _buildSection(
              context: context,
              title: 'Правовая информация',
              icon: Icons.gavel,
              children: [
                _buildListTile(
                  title: 'Политика конфиденциальности',
                  onTap: () => _showPrivacyPolicy(context),
                ),
                _buildListTile(
                  title: 'Условия использования',
                  onTap: () => _showTermsOfService(context),
                ),
                _buildListTile(
                  title: 'Лицензии',
                  onTap: () => _showLicenses(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Разработчики
            _buildSection(
              context: context,
              title: 'Разработчики',
              icon: Icons.code,
              children: [
                const ListTile(
                  leading: Icon(Icons.person, size: 20),
                  title: Text('Команда PulseFit Pro'),
                  subtitle: Text('Создано с ❤️ для вашего здоровья'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Копирайт
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '© 2024 PulseFit Pro',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Все права защищены',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Сделано в России 🇷🇺',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=PulseFit Pro Support',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback: copy to clipboard
      await Clipboard.setData(ClipboardData(text: email));
    }
  }

  Future<void> _launchTelegram(String username) async {
    final Uri telegramUri = Uri.parse('https://t.me/$username');
    
    if (await canLaunchUrl(telegramUri)) {
      await launchUrl(telegramUri);
    } else {
      // Fallback: copy to clipboard
      await Clipboard.setData(ClipboardData(text: username));
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: 'Политика конфиденциальности',
        icon: Icons.privacy_tip_rounded,
        contentWidget: const SingleChildScrollView(
          child: Text(
            '1. Сбор данных\nМы собираем только необходимые данные для работы приложения: параметры тела, цели тренировок, фотографии прогресса.\n\n2. Хранение данных\nВсе ваши данные хранятся локально на вашем устройстве. Мы не передаем их третьим лицам без вашего согласия.\n\n3. Использование AI\nДля анализа изображений мы используем OpenAI API. Изображения передаются в зашифрованном виде и не сохраняются.\n\n4. Ваши права\nВы можете в любое время удалить все данные через настройки приложения.\n\n5. Контакты\nПо вопросам конфиденциальности: privacy@pulsefit.pro',
            style: TextStyle(color: kContentMedium, fontSize: 14),
            textAlign: TextAlign.left,
          ),
        ),
        confirmText: 'Закрыть',
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: 'Условия использования',
        icon: Icons.description_rounded,
        contentWidget: const SingleChildScrollView(
          child: Text(
            '1. Принятие условий\nИспользуя PulseFit Pro, вы соглашаетесь с данными условиями.\n\n2. Использование приложения\nПриложение предназначено для информационных целей и не заменяет консультацию с врачом или тренером.\n\n3. Ответственность\nМы не несем ответственности за результаты использования приложения. Тренируйтесь с осторожностью.\n\n4. Изменения\nМы можем изменять условия использования. Продолжение использования означает согласие с новыми условиями.\n\n5. Контакты\nПо вопросам: legal@pulsefit.pro',
            style: TextStyle(color: kContentMedium, fontSize: 14),
            textAlign: TextAlign.left,
          ),
        ),
        confirmText: 'Закрыть',
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => NoirGlassDialog(
        title: 'Лицензии',
        icon: Icons.article_rounded,
        content: 'Приложение использует следующие библиотеки:\n\n• Flutter SDK\n• Riverpod\n• OpenAI API\n• Flutter Local Notifications\n• Image Picker\n• Shared Preferences\n• SQLite\n\nПолный список лицензий доступен в исходном коде.',
        confirmText: 'Закрыть',
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }
}
