// screens.dart
// ============================================================================
// TRIBUNAL: All UI Screens
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config.dart';
import 'models.dart';
import 'providers.dart';
import 'services.dart';
import 'utils.dart';
import 'widgets.dart';

// ============================================================================
// LOADING SCREEN
// ============================================================================

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Loading Tribunal...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutral600,
              ),
            ),
          ],
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                error,
                style: const TextStyle(
                  color: AppColors.neutral600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
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
    if (zetraMailController.text.isEmpty ||
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
      final user = await authService.signIn(
        zetramail: zetraMailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      // Navigate to OTP screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.otp);
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
      appBar: AppBar(
        title: const Text('Tribunal'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Welcome to Tribunal',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Where validated ideas meet expert judgment',
              style: TextStyle(
                color: AppColors.neutral600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            TextField(
              controller: zetraMailController,
              decoration: InputDecoration(
                labelText: 'ZetraMail Address',
                hintText: 'your@zetramail.com',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
              ),
              obscureText: true,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : const Text('Sign In'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to forgot password
                },
                child: const Text('Forgot your password?'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                "Don't have an account?",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to signup
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neutral100,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('Create Account'),
            ),
          ],
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
  late List<TextEditingController> codeControllers;
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    codeControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleVerifyOtp() async {
    final code = codeControllers.map((c) => c.text).join();

    if (code.length != 6) {
      setState(() => errorMessage = 'Please enter all 6 digits');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = ref.read(authProvider).value;

      if (user == null) throw Exception('User not found');

      // TODO: Get internal email from somewhere (store during login)
      // For now, we'll need to refactor auth flow to pass this
      final result = await authService.verifyOtp(
        internalEmail: 'internal_email',
        otpCode: code,
      );

      if (result && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        setState(() {
          errorMessage = 'Invalid OTP code';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Code'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Enter the 6-digit code sent to your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.neutral600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 48,
                  height: 48,
                  child: TextField(
                    controller: codeControllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: isLoading ? null : _handleVerifyOtp,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HOME SCREEN (Browse)
// ============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final overviewsAsync = ref.watch(searchedOverviewsProvider);
    final filter = ref.watch(filterProvider);
    final search = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tribunal'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    ref.read(searchProvider.notifier).setQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search ideas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              ref
                                  .read(searchProvider.notifier)
                                  .clear();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: filter == null,
                        onTap: () {
                          ref.read(filterProvider.notifier).clear();
                        },
                      ),
                      ...IdeaCategories.all.map(
                        (category) => _FilterChip(
                          label: category,
                          isSelected: filter == category,
                          onTap: () {
                            ref
                                .read(filterProvider.notifier)
                                .setCategory(category);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: overviewsAsync.when(
              data: (overviews) {
                if (overviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: AppColors.neutral300,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'No ideas found',
                          style: TextStyle(
                            color: AppColors.neutral600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: overviews.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CaseCard(overview: overviews[index]),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImportModal(context),
        tooltip: 'Import Crucible Report',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showImportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ImportModal(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.neutral200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.neutral700,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// IMPORT MODAL
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

      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(
        AppRoutes.overviewDetail,
        arguments: overview.id,
      );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Import Crucible Report',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Overview ID',
                hintText: 'Paste the ID or link',
                prefixIcon: const Icon(Icons.paste),
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: isLoading ? null : _handleImport,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Import'),
            ),
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
              // Header
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

              // Tabs
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
                          // Idea Tab
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(overview.fullIdeaContent),
                            ),
                          ),

                          // Analysis Tab
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (overview.findings != null) ...[
                                    Text(
                                      'Findings',
                                      style:
                                          Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      overview.findings.toString(),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],
                                  if (overview.arbiterReport != null) ...[
                                    Text(
                                      "Arbiter's Report",
                                      style:
                                          Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      overview.arbiterReport.toString(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Reviews Tab
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
                                      ...reviews.map((review) =>
                                          ReviewCard(review: review)),
                                  ],
                                ),
                              ),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) => Center(
                              child: Text('Error: $err'),
                            ),
                          ),

                          // Consensus Tab
                          reportAsync.when(
                            data: (report) {
                              if (report == null) {
                                return const Center(
                                  child: Text(
                                    'Waiting for more reviews...',
                                  ),
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
                                          borderRadius:
                                              BorderRadius.circular(
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
                                      ScoreDisplay(
                                        scores: report.averageScores,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (report.areasOfAgreement != null)
                                        _ReportSection(
                                          title: 'Areas of Agreement',
                                          content: report
                                              .areasOfAgreement ??
                                              '',
                                        ),
                                      if (report.areasOfDisagreement != null)
                                        _ReportSection(
                                          title: 'Areas of Disagreement',
                                          content: report
                                              .areasOfDisagreement ??
                                              '',
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) => Center(
                              child: Text('Error: $err'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Submit Review Button
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
                        Navigator.of(context).pushNamed(
                          AppRoutes.reviewForm,
                          arguments: (overviewId, user.id),
                        );
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
        error: (err, stack) =>
            Center(child: Text('Error: $err')),
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
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
                        _updateScore(
                            reviewForm, key, val.toInt());
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
                    .read(
                        reviewFormProvider(
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
                    .read(
                        reviewFormProvider(
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
                    .read(
                        reviewFormProvider(
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
                    .read(
                        reviewFormProvider(
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
                        .read(
                            reviewFormProvider(
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
                                  .read(
                                      reviewFormProvider((widget.overviewId,
                                              widget.expertId))
                                          .notifier)
                                  .setRecommendation(val);
                            }
                          },
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(rec),
                        ),
                      ],
                    ),
                  ),
                );
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
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value),
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
