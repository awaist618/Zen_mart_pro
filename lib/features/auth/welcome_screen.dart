import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Logo/Illustration Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Zen MArt Pro',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete Multi-Vendor Marketplace',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Shop • Sell • Deliver • Manage',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Get Started'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Footer
              Text(
                'POWERED BY',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Zenvyro Labs',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
