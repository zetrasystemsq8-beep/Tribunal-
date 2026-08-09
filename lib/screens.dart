// screens.dart
// ============================================================================
// TRIBUNAL: All UI Screens
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config.dart';
import 'models.dart';
import 'providers.dart';
import 'services.dart';
import 'utils.dart';
import 'widgets.dart';

// ============================================================================
// DARK BRAND PALETTE (used app-wide now)
// ============================================================================

class _Dark {
  static const bgTop = Color(0xFF0B0F14);
  static const bgBottom = Color(0xFF141B23);
  static const card = Color(0xFF1B2530);
  static const cardBorder = Color(0xFF2A3844);
  static const accentStart = Color(0xFF3B82F6);
  static const accentEnd = Color(0xFF60A5FA);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFF8B96A3);
  static const textMuted = Color(0xFF5C6773);
}

class _BlobBackground extends StatelessWidget {
  final Widget child;
  const _BlobBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Dark.bgTop, _Dark.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _blob(220, _Dark.accentStart.withOpacity(0.22)),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _blob(260, _Dark.accentEnd.withOpacity(0.16)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _GlowIcon({required this.icon, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Dark.accentStart, _Dark.accentEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: _Dark.accentStart.withOpacity(0.45),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const _DarkField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.enabled = true,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Dark.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Dark.cardBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: const TextStyle(color: _Dark.textPrimary, fontSize: 15),
        cursorColor: _Dark.accentEnd,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _Dark.textMuted, fontSize: 15),
          prefixIcon: Icon(icon, color: _Dark.textSecondary, size: 20),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData? trailingIcon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    this.trailingIcon,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_Dark.accentStart, _Dark.accentEnd],
          ),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: _Dark.accentStart.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(trailingIcon, color: Colors.white, size: 18),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkErrorCard extends StatelessWidget {
  final String message;
  const _DarkErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF8A8A), size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Color(0xFFFF8A8A),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ONBOARDING SCREEN (always shown first)
// ============================================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.fact_check_outlined,
      title: 'Only proven ideas',
      description:
          'Tribunal never accepts a raw idea. Every case here already survived Crucible\'s AI stress test before a human ever sees it.',
    ),
    _OnboardingPage(
      icon: Icons.groups_2_outlined,
      title: 'Real expert judgment',
      description:
          'Qualified reviewers weigh in with structured scoring and honest, qualitative assessment — no popularity contest, no noise.',
    ),
    _OnboardingPage(
      icon: Icons.verified_outlined,
      title: 'A credible verdict',
      description:
          'Once enough experts weigh in, Tribunal produces a clear consensus report an idea can actually stand on.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.go('/');
    }
  }

  void _skip() {
    context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: _Dark.bgTop,
      body: _BlobBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: _Dark.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GlowIcon(icon: page.icon, size: 96),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _Dark.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _Dark.textSecondary,
                              fontSize: 14.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? _Dark.accentEnd
                            : _Dark.textMuted.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: _GradientButton(
                  label: isLastPage ? 'Get Started' : 'Next',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING SCREEN
// ============================================================================

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BlobBackground(
      child: const Center(
        child: CircularProgressIndicator(
          color: _Dark.accentEnd,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR SCREEN
// ============================================================================

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BlobBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: _Dark.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: const TextStyle(color: _Dark.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: _GradientButton(
                  label: 'Back to Sign In',
                  onPressed: () => context.go('/login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN SCREEN
// ============================================================================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController zetraMailController;
  late TextEditingController passwordController;
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    zetraMailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    zetraMailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (zetraMailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(
        zetramail: zetraMailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      context.go('/otp');
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Dark.bgTop,
      body: _BlobBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Center(child: _GlowIcon(icon: Icons.gavel_rounded)),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _Dark.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Sign in with your ZetraMail address',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _Dark.textSecondary, fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _DarkField(
                  controller: zetraMailController,
                  hint: 'ZetraMail address',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                _DarkField(
                  controller: passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: obscurePassword,
                  enabled: !isLoading,
                  onSubmitted: (_) => _handleLogin(),
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _Dark.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined, size: 14, color: _Dark.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Secured by your Zetra ID',
                      style: TextStyle(fontSize: 12, color: _Dark.textMuted),
                    ),
                  ],
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DarkErrorCard(message: errorMessage!),
                ],
                const SizedBox(height: AppSpacing.xxl),
                _GradientButton(
                  label: 'Log In',
                  trailingIcon: Icons.arrow_forward_rounded,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_person_outlined,
                        size: 13, color: _Dark.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Reviewer access is by invitation only',
                      style: TextStyle(fontSize: 11.5, color: _Dark.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// OTP SCREEN
// ============================================================================

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late TextEditingController codeController;
  String? errorMessage;
  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      final digitsOnly = data!.text!.replaceAll(RegExp(r'\D'), '');
      final code =
          digitsOnly.length > 6 ? digitsOnly.substring(0, 6) : digitsOnly;
      codeController.text = code;
      setState(() {});
    }
  }

  void _handleVerifyOtp() async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      setState(() => errorMessage = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      final result = await authService.verifyOtp(
        otpCode: code,
      );

      if (!mounted) return;

      if (result) {
        context.go('/home');
      } else {
        setState(() {
          errorMessage = 'Incorrect code. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _handleResend() async {
    setState(() {
      isResending = true;
      errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendOtp();

      if (!mounted) return;
      setState(() => isResending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new code has been sent to your ZetraMail'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Dark.bgTop,
      body: _BlobBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Center(
                  child: _GlowIcon(icon: Icons.mark_email_read_outlined),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Check your ZetraMail',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _Dark.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Copy the 6-digit code from your inbox and paste it below',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _Dark.textSecondary, fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  decoration: BoxDecoration(
                    color: _Dark.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _Dark.cardBorder),
                  ),
                  child: TextField(
                    controller: codeController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 10,
                      color: _Dark.textPrimary,
                    ),
                    cursorColor: _Dark.accentEnd,
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 10,
                        color: _Dark.textMuted,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded,
                        size: 18, color: _Dark.textSecondary),
                    label: const Text(
                      'Paste code',
                      style: TextStyle(color: _Dark.textSecondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _Dark.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DarkErrorCard(message: errorMessage!),
                ],
                const SizedBox(height: AppSpacing.xl),
                _GradientButton(
                  label: 'Verify & Continue',
                  trailingIcon: Icons.arrow_forward_rounded,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleVerifyOtp,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: isResending ? null : _handleResend,
                    child: isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_Dark.accentEnd),
                            ),
                          )
                        : const Text(
                            "Didn't get a code? Resend",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _Dark.accentEnd,
                            ),
                          ),
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

// ============================================================================
// HOME SCREEN (Browse) — redesigned, dark theme
// ============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overviewsAsync = ref.watch(searchedOverviewsProvider);
    final filter = ref.watch(filterProvider);
    final search = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: _Dark.bgTop,
      body: _BlobBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: _Dark.accentEnd,
            backgroundColor: _Dark.card,
            onRefresh: () async {
              ref.invalidate(overviewListProvider);
              ref.invalidate(searchedOverviewsProvider);
              await ref.read(searchedOverviewsProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tribunal',
                          style: TextStyle(
                            color: _Dark.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _Dark.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _Dark.cardBorder),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              color: _Dark.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Navigate to profile
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: _DarkField(
                      controller: searchController,
                      hint: 'Search ideas...',
                      icon: Icons.search_rounded,
                      onChanged: (value) {
                        ref.read(searchProvider.notifier).setQuery(value);
                      },
                      suffix: search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: _Dark.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                searchController.clear();
                                ref.read(searchProvider.notifier).clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      children: [
                        _DarkFilterChip(
                          label: 'All',
                          isSelected: filter == null,
                          onTap: () => ref.read(filterProvider.notifier).clear(),
                        ),
                        ...IdeaCategories.all.map(
                          (category) => _DarkFilterChip(
                            label: category,
                            isSelected: filter == category,
                            onTap: () => ref
                                .read(filterProvider.notifier)
                                .setCategory(category),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
                overviewsAsync.when(
                  data: (overviews) {
                    if (overviews.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyHomeState(),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _DarkCaseCard(
                                overview: overviews[index],
                              ),
                            );
                          },
                          childCount: overviews.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: _Dark.accentEnd),
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: _Dark.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 96),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _GradientFAB(
        onPressed: () => _showImportModal(context),
      ),
    );
  }

  void _showImportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImportModal(),
    );
  }
}

class _GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_Dark.accentStart, _Dark.accentEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: _Dark.accentStart.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _Dark.card,
                shape: BoxShape.circle,
                border: Border.all(color: _Dark.cardBorder),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 32,
                color: _Dark.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No ideas yet',
              style: TextStyle(
                color: _Dark.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Import a Crucible Overview by ID to bring it to Tribunal for expert review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Dark.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DarkFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [_Dark.accentStart, _Dark.accentEnd],
                  )
                : null,
            color: isSelected ? null : _Dark.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected ? Colors.transparent : _Dark.cardBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _Dark.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkCaseCard extends StatelessWidget {
  final Overview overview;
  const _DarkCaseCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go('/overview/${overview.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _Dark.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _Dark.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overview.title,
                          style: const TextStyle(
                            color: _Dark.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          overview.oneLiner,
                          style: const TextStyle(
                            color: _Dark.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _Dark.accentStart.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: _Dark.accentEnd,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _Dark.accentStart.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      overview.category,
                      style: const TextStyle(
                        color: _Dark.accentEnd,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(overview.createdAt),
                    style: const TextStyle(
                      color: _Dark.textMuted,
                      fontSize: 11.5,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

// ============================================================================
// IMPORT MODAL — dark themed
// ============================================================================

class ImportModal extends ConsumerStatefulWidget {
  const ImportModal({Key? key}) : super(key: key);

  @override
  ConsumerState<ImportModal> createState() => _ImportModalState();
}

class _ImportModalState extends ConsumerState<ImportModal> {
  late TextEditingController idController;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  void _handleImport() async {
    final id = idController.text.trim();

    if (id.isEmpty) {
      setState(() => errorMessage = 'Please enter an ID');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final overviewService = ref.read(overviewServiceProvider);
      final overview = await overviewService.importOverviewById(id);

      if (!mounted) return;

      ref.invalidate(overviewListProvider);
      ref.invalidate(searchedOverviewsProvider);

      Navigator.of(context).pop();
      context.go('/overview/${overview.id}');
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: _Dark.bgBottom,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _Dark.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Import Crucible Report',
              style: TextStyle(
                color: _Dark.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Paste the Overview ID or link from Crucible',
              style: TextStyle(color: _Dark.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DarkField(
              controller: idController,
              hint: 'Overview ID',
              icon: Icons.tag_rounded,
              enabled: !isLoading,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _DarkErrorCard(message: errorMessage!),
            ],
            const SizedBox(height: AppSpacing.xl),
            _GradientButton(
              label: 'Import',
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleImport,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// OVERVIEW DETAIL SCREEN
// ============================================================================

class OverviewDetailScreen extends ConsumerWidget {
  final String overviewId;

  const OverviewDetailScreen({
    Key? key,
    required this.overviewId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewDetailProvider(overviewId));
    final reviewsAsync = ref.watch(reviewsForOverviewProvider(overviewId));
    final reportAsync = ref.watch(finalReportProvider(overviewId));
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        elevation: 0,
      ),
      body: overviewAsync.when(
        data: (overview) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      overview.oneLiner,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        _Badge(label: overview.category),
                        if (overview.ownerName != null)
                          _Badge(label: 'by ${overview.ownerName}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Idea'),
                        Tab(text: 'Analysis'),
                        Tab(text: 'Reviews'),
                        Tab(text: 'Consensus'),
                      ],
                    ),
                    SizedBox(
                      height: 600,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(overview.fullIdeaContent),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (overview.findings != null) ...[
                                    Text(
                                      'Findings',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(overview.findings.toString()),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],
                                  if (overview.arbiterReport != null) ...[
                                    Text(
                                      "Arbiter's Report",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(overview.arbiterReport.toString()),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          reviewsAsync.when(
                            data: (reviews) => SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  children: [
                                    if (reviews.isEmpty)
                                      const Center(
                                        child: Text('No reviews yet'),
                                      )
                                    else
                                      ...reviews.map(
                                        (review) => ReviewCard(review: review),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (err, _) => Center(child: Text('Error: $err')),
                          ),
                          reportAsync.when(
                            data: (report) {
                              if (report == null) {
                                return const Center(
                                  child: Text('Waiting for more reviews...'),
                                );
                              }

                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                            AppSpacing.lg),
                                        decoration: BoxDecoration(
                                          color: VerdictDefinitions
                                                  .verdictColors[
                                              report.finalVerdict]
                                              ?.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.lg),
                                          border: Border.all(
                                            color: VerdictDefinitions
                                                    .verdictColors[
                                                report.finalVerdict] ??
                                                AppColors.primary,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Final Verdict',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.sm),
                                            Text(
                                              report.finalVerdict,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: VerdictDefinitions
                                                        .verdictColors[
                                                    report.finalVerdict],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Text(
                                        'Average Scores',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      ScoreDisplay(scores: report.averageScores),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (report.areasOfAgreement != null)
                                        _ReportSection(
                                          title: 'Areas of Agreement',
                                          content:
                                              report.areasOfAgreement ?? '',
                                        ),
                                      if (report.areasOfDisagreement != null)
                                        _ReportSection(
                                          title: 'Areas of Disagreement',
                                          content:
                                              report.areasOfDisagreement ?? '',
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (err, _) => Center(child: Text('Error: $err')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              userProfile.when(
                data: (user) {
                  if (user == null) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to review'),
                            ),
                          );
                        },
                        child: const Text('Sign In to Review'),
                      ),
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/review/$overviewId/${user.id}');
                      },
                      child: const Text('Submit Your Review'),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('Loading...'),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final String content;

  const _ReportSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(content),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ============================================================================
// REVIEW FORM SCREEN
// ============================================================================

class ReviewFormScreen extends ConsumerStatefulWidget {
  final String overviewId;
  final String expertId;

  const ReviewFormScreen({
    Key? key,
    required this.overviewId,
    required this.expertId,
  }) : super(key: key);

  @override
  ConsumerState<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends ConsumerState<ReviewFormScreen> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final reviewForm = ref.read(
      reviewFormProvider((widget.overviewId, widget.expertId)),
    );

    if (!reviewForm.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final reviewService = ref.read(reviewServiceProvider);
      await reviewService.submitReview(reviewForm);

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(SuccessMessages.reviewSubmitted)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewForm = ref.watch(
      reviewFormProvider((widget.overviewId, widget.expertId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Review'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate the following dimensions (0-100)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...ReviewDimensions.dimensions.map((dimension) {
              final key = ReviewDimensions.dimensionKeys[dimension]!;
              final value = _getScoreValue(reviewForm, key);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dimension,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            '${value ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Slider(
                      value: (value ?? 0).toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (val) {
                        _updateScore(reviewForm, key, val.toInt());
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Qualitative Assessment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _ReviewTextField(
              label: 'Strengths',
              hint: 'What are the strongest aspects of this idea?',
              value: reviewForm.strengths,
              onChanged: (val) {
                ref
                    .read(reviewFormProvider(
                            (widget.overviewId, widget.expertId))
                        .notifier)
                    .setStrengths(val);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReviewTextField(
              label: 'Weaknesses',
              hint: 'What areas need improvement?',
              value: reviewForm.weaknesses,
              onChanged: (val) {
                ref
                    .read(reviewFormProvider(
                            (widget.overviewId, widget.expertId))
                        .notifier)
                    .setWeaknesses(val);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReviewTextField(
              label: 'Risks',
              hint: 'What risks or concerns did you identify?',
              value: reviewForm.risks,
              onChanged: (val) {
                ref
                    .read(reviewFormProvider(
                            (widget.overviewId, widget.expertId))
                        .notifier)
                    .setRisks(val);
              },
              required: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReviewTextField(
              label: 'Required Changes',
              hint: 'What specific changes or revisions are needed?',
              value: reviewForm.requiredChanges,
              onChanged: (val) {
                ref
                    .read(reviewFormProvider(
                            (widget.overviewId, widget.expertId))
                        .notifier)
                    .setRequiredChanges(val);
              },
              required: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Final Recommendation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...ReviewDimensions.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(reviewFormProvider(
                                (widget.overviewId, widget.expertId))
                            .notifier)
                        .setRecommendation(rec);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: reviewForm.recommendation == rec
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: reviewForm.recommendation == rec
                            ? AppColors.primary
                            : AppColors.neutral200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: rec,
                          groupValue: reviewForm.recommendation,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(reviewFormProvider((
                                    widget.overviewId,
                                    widget.expertId
                                  )).notifier)
                                  .setRecommendation(val);
                            }
                          },
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(rec)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                child: const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _getScoreValue(Review review, String key) {
    switch (key) {
      case 'originality':
        return review.originality;
      case 'technical_feasibility':
        return review.technicalFeasibility;
      case 'economic_feasibility':
        return review.economicFeasibility;
      case 'ethics':
        return review.ethics;
      case 'legal_compliance':
        return review.legalCompliance;
      case 'social_impact':
        return review.socialImpact;
      case 'environmental_impact':
        return review.environmentalImpact;
      default:
        return 0;
    }
  }

  void _updateScore(Review review, String key, int value) {
    final notifier = ref.read(
      reviewFormProvider((widget.overviewId, widget.expertId)).notifier,
    );

    switch (key) {
      case 'originality':
        notifier.setOriginality(value);
      case 'technical_feasibility':
        notifier.setTechnicalFeasibility(value);
      case 'economic_feasibility':
        notifier.setEconomicFeasibility(value);
      case 'ethics':
        notifier.setEthics(value);
      case 'legal_compliance':
        notifier.setLegalCompliance(value);
      case 'social_impact':
        notifier.setSocialImpact(value);
      case 'environmental_impact':
        notifier.setEnvironmentalImpact(value);
    }
  }
}

class _ReviewTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final Function(String) onChanged;
  final bool required;

  const _ReviewTextField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (required)
              const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value),
          minLines: 3,
          maxLines: 6,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
