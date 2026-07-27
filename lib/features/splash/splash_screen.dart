import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_info.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/providers/app_providers.dart';

/// Branded launch screen (FR-01, key screen "Splash / launch").
///
/// Prepares local services and routes to the correct first screen: onboarding
/// for new users, Home for returning users. Never waits on the network.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.slow)..forward();

  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    // Brief branded pause; startup work already happened in main().
    await Future<void>.delayed(AppMotion.splash);
    if (!mounted) return;
    final onboarded = ref.read(onboardingCompleteProvider);
    context.go(onboarded ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final rise = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: rise,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: const BoxDecoration(
                    gradient: BrandGradient.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded,
                      size: 56, color: Colors.white),
                ),
                AppSpacing.gapLg,
                Text(AppInfo.appName, style: theme.textTheme.headlineSmall),
                AppSpacing.gapXs,
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxxl),
                  child: Text(
                    AppInfo.tagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
