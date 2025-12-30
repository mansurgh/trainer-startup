import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_alert.dart';
import '../l10n/app_localizations.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  State<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> 
    with SingleTickerProviderStateMixin {
  String _selectedPlan = 'year'; // 'month' or 'year'
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // "Sorry, but I want it" Title with shimmer effect
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: const [
                            Colors.white,
                            Color(0xFFCCCCCC),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          transform: _ShimmerGradientTransform(_shimmerController.value),
                        ).createShader(bounds);
                      },
                      child: Text(
                        isRussian ? 'Прости, но я\nхочу это' : 'Sorry, but I\nwant it',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                     .slideY(begin: -0.1, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: 40),
                    
                    // G-Wagon Image - requires PNG with transparent background
                    // If white bg is visible, replace gwagon.png with a transparent PNG
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/gwagon.png',
                        height: 280,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 280,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[900]!, Colors.grey[850]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              size: 100,
                              color: Colors.grey[700],
                            ),
                          );
                        },
                      ),
                    ).animate()
                     .fadeIn(duration: 800.ms, delay: 200.ms)
                     .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                    
                    const SizedBox(height: 40),
                    
                    // Benefits - Minimal Style with checkmarks
                    _buildMinimalBenefit(
                      isRussian ? 'Персонализированные тренировки' : 'Personalized workouts',
                      delay: 400,
                    ),
                    const SizedBox(height: 16),
                    _buildMinimalBenefit(
                      isRussian ? 'AI анализ техники' : 'AI form feedback',
                      delay: 500,
                    ),
                    const SizedBox(height: 16),
                    _buildMinimalBenefit(
                      isRussian ? 'Отслеживание прогресса' : 'Progress tracking',
                      delay: 600,
                    ),
                    const SizedBox(height: 16),
                    _buildMinimalBenefit(
                      isRussian ? 'Неограниченный AI чат' : 'Unlimited AI chat',
                      delay: 700,
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Pricing Cards (selectable buttons)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'month';
                              });
                            },
                            child: _buildPriceCard(
                              price: '\$9.99',
                              period: isRussian ? 'месяц' : 'month',
                              isPopular: false,
                              isSelected: _selectedPlan == 'month',
                            ),
                          ).animate()
                           .fadeIn(duration: 600.ms, delay: 800.ms)
                           .slideX(begin: -0.1, end: 0),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'year';
                              });
                            },
                            child: _buildPriceCard(
                              price: '\$59.99',
                              period: isRussian ? 'год' : 'year',
                              isPopular: true,
                              isSelected: _selectedPlan == 'year',
                              savings: isRussian ? 'ЭКОНОМИЯ 40%' : 'SAVE 40%',
                            ),
                          ).animate()
                           .fadeIn(duration: 600.ms, delay: 900.ms)
                           .slideX(begin: 0.1, end: 0),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Subscribe Button with premium gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            AppAlert.show(
                              context,
                              title: isRussian ? 'Обработка платежа' : 'Processing payment',
                              description: isRussian 
                                  ? 'Обработка платежа за ${_selectedPlan == 'year' ? 'годовой' : 'месячный'} план...'
                                  : 'Processing payment for $_selectedPlan plan...',
                              type: AlertType.info,
                              duration: const Duration(seconds: 3),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isRussian ? 'Подписаться' : 'Subscribe',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 1000.ms)
                     .slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Terms text
                    Text(
                      isRussian 
                          ? 'Отмена в любое время. Оплата через App Store.'
                          : 'Cancel anytime. Billed through App Store.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                     .fadeIn(duration: 400.ms, delay: 1100.ms),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMinimalBenefit(String text, {int delay = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).animate()
     .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
     .slideX(begin: -0.05, end: 0);
  }
  
  Widget _buildPriceCard({
    required String price,
    required String period,
    required bool isPopular,
    required bool isSelected,
    String? savings,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isSelected 
            ? LinearGradient(
                colors: [Colors.grey[900]!, Colors.grey[850]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey[700]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isPopular && savings != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                savings,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (isPopular && savings != null) const SizedBox(height: 12),
          Text(
            price,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              shadows: isSelected ? [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ] : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '/$period',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Shimmer gradient transform for premium title effect
class _ShimmerGradientTransform extends GradientTransform {
  final double progress;
  
  const _ShimmerGradientTransform(this.progress);
  
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final offset = bounds.width * (progress * 2 - 0.5);
    return Matrix4.translationValues(offset, 0, 0);
  }
}
