import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [colorScheme.primary.withOpacity(isLight ? 0.1 : 0.05), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo Container
                      Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: isLight ? Colors.black.withOpacity(0.05) : Colors.black.withOpacity(0.2), 
                                blurRadius: isLight ? 40 : 30, 
                                offset: const Offset(0, 10)
                              ),
                            ],
                            border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.1)) : null,
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Image.asset(
                            'assets/images/image.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.shopping_bag_rounded,
                              size: 64,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Zen Mart Pro',
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontSize: 38,
                          letterSpacing: -1.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'The next generation of multi-vendor shopping & management experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            height: 1.6,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Feature Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: const [
                            _FeatureChip(icon: Icons.storefront_rounded, label: 'PREMIUM VENDORS'),
                            _FeatureChip(icon: Icons.bolt_rounded, label: 'EXPRESS DELIVERY'),
                            _FeatureChip(icon: Icons.shield_moon_rounded, label: 'SECURE PAY'),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Action Area
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isLight ? colorScheme.surface.withOpacity(0.8) : colorScheme.surface.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
                                boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40)] : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => context.push('/signup'),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('GET STARTED'),
                                        SizedBox(width: 12),
                                        Icon(Icons.arrow_forward_rounded, size: 20),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () => context.push('/login'),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: colorScheme.onSurface.withOpacity(0.7), 
                                          fontSize: 14, 
                                          fontWeight: FontWeight.w500
                                        ),
                                        children: [
                                          const TextSpan(text: 'Already a member? '),
                                          TextSpan(
                                            text: 'Login',
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Powered By
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              'DESIGNED BY',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.3),
                                fontSize: 9,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Zenvyro Labs',
                              style: TextStyle(
                                color: colorScheme.onBackground,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontWeight: FontWeight.w800, 
              fontSize: 11, 
              letterSpacing: 0.5
            ),
          ),
        ],
      ),
    );
  }
}
