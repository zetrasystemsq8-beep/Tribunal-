// providers.dart
// ============================================================================
// TRIBUNAL: State Management (Riverpod)
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'services.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

final authServiceProvider = Provider((ref) => AuthService());
final overviewServiceProvider = Provider((ref) => OverviewService());
final reviewServiceProvider = Provider((ref) => ReviewService());
final reportServiceProvider = Provider((ref) => ReportService());
final profileServiceProvider = Provider((ref) => ProfileService());

// ============================================================================
// AUTH STATE
// ============================================================================

final authProvider = FutureProvider<UserProfile?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

class OtpNotifier extends StateNotifier<String> {
  OtpNotifier() : super('');

  void setOtp(String code) {
    state = code;
  }

  void clear() {
    state = '';
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, String>(
  (ref) => OtpNotifier(),
);

// ============================================================================
// OVERVIEW STATE
// ============================================================================

final overviewListProvider = FutureProvider<List<Overview>>((ref) async {
  final overviewService = ref.watch(overviewServiceProvider);
  return overviewService.fetchAllOverviews();
});

final overviewDetailProvider =
    FutureProvider.family<Overview, String>((ref, overviewId) async {
  final overviewService = ref.watch(overviewServiceProvider);
  return overviewService.fetchOverviewById(overviewId);
});

final overviewSearchProvider =
    FutureProvider.family<List<Overview>, String>((ref, keyword) async {
  final overviewService = ref.watch(overviewServiceProvider);
  if (keyword.isEmpty) {
    return overviewService.fetchAllOverviews();
  }
  return overviewService.searchByKeyword(keyword);
});

final overviewCategoryProvider =
    FutureProvider.family<List<Overview>, String>((ref, category) async {
  final overviewService = ref.watch(overviewServiceProvider);
  return overviewService.searchByCategory(category);
});

// ============================================================================
// REVIEW STATE
// ============================================================================

final reviewsForOverviewProvider =
    FutureProvider.family<List<Review>, String>((ref, overviewId) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.fetchReviewsForOverview(overviewId);
});

final reviewCountProvider =
    FutureProvider.family<int, String>((ref, overviewId) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getReviewCount(overviewId);
});

final expertReviewProvider =
    FutureProvider.family<Review?, (String, String)>((ref, params) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.fetchExpertReview(params.$1, params.$2);
});

// ============================================================================
// REVIEW FORM STATE
// ============================================================================

class ReviewFormNotifier extends StateNotifier<Review> {
  ReviewFormNotifier(String overviewId, String expertId)
      : super(Review(
          id: '',
          overviewId: overviewId,
          expertId: expertId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

  void setOriginality(int value) {
    state = state.copyWith(originality: value);
  }

  void setTechnicalFeasibility(int value) {
    state = state.copyWith(technicalFeasibility: value);
  }

  void setEconomicFeasibility(int value) {
    state = state.copyWith(economicFeasibility: value);
  }

  void setEthics(int value) {
    state = state.copyWith(ethics: value);
  }

  void setLegalCompliance(int value) {
    state = state.copyWith(legalCompliance: value);
  }

  void setSocialImpact(int value) {
    state = state.copyWith(socialImpact: value);
  }

  void setEnvironmentalImpact(int value) {
    state = state.copyWith(environmentalImpact: value);
  }

  void setRisks(String value) {
    state = state.copyWith(risks: value);
  }

  void setStrengths(String value) {
    state = state.copyWith(strengths: value);
  }

  void setWeaknesses(String value) {
    state = state.copyWith(weaknesses: value);
  }

  void setRequiredChanges(String value) {
    state = state.copyWith(requiredChanges: value);
  }

  void setRecommendation(String value) {
    state = state.copyWith(recommendation: value);
  }

  void reset() {
    state = Review(
      id: '',
      overviewId: state.overviewId,
      expertId: state.expertId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool isValid() {
    return state.originality != null &&
        state.technicalFeasibility != null &&
        state.economicFeasibility != null &&
        state.ethics != null &&
        state.legalCompliance != null &&
        state.socialImpact != null &&
        state.environmentalImpact != null &&
        (state.strengths?.isNotEmpty ?? false) &&
        (state.weaknesses?.isNotEmpty ?? false) &&
        (state.recommendation?.isNotEmpty ?? false);
  }
}

final reviewFormProvider = StateNotifierProvider.family<ReviewFormNotifier, Review,
    (String, String)>((ref, params) {
  return ReviewFormNotifier(params.$1, params.$2);
});

// ============================================================================
// SUBMIT REVIEW ACTION
// ============================================================================

final submitReviewProvider =
    FutureProvider.family<Review, Review>((ref, review) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.submitReview(review);
});

final updateReviewProvider =
    FutureProvider.family<Review, Review>((ref, review) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.updateReview(review);
});

// ============================================================================
// FINAL REPORT STATE
// ============================================================================

final finalReportProvider =
    FutureProvider.family<FinalReport?, String>((ref, overviewId) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.fetchFinalReport(overviewId);
});

final generateReportProvider = FutureProvider.family<FinalReport, (String, List<Review>)>((ref, params) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.generateFinalReport(params.$1, params.$2);
});

// ============================================================================
// IMPORT OVERVIEW STATE
// ============================================================================

final importOverviewProvider =
    FutureProvider.family<Overview, String>((ref, overviewId) async {
  final overviewService = ref.watch(overviewServiceProvider);
  return overviewService.importOverviewById(overviewId);
});

// ============================================================================
// PROFILE STATE
// ============================================================================

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authUser = ref.watch(authProvider);
  return authUser.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final updateProfileProvider = FutureProvider.family<UserProfile, (String, String?, String?, String?)>((ref, params) async {
  final profileService = ref.watch(profileServiceProvider);
  final userId = params.$1;
  final username = params.$2;
  final field = params.$3;
  final avatarUrl = params.$4;

  return profileService.updateProfile(
    userId: userId,
    username: username,
    field: field,
    avatarUrl: avatarUrl,
  );
});

// ============================================================================
// NAVIGATION STATE
// ============================================================================

class NavigationNotifier extends StateNotifier<String> {
  NavigationNotifier() : super('/');

  void navigateTo(String route) {
    state = route;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, String>(
  (ref) => NavigationNotifier(),
);

// ============================================================================
// LOADING STATE
// ============================================================================

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool isLoading) {
    state = isLoading;
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>(
  (ref) => LoadingNotifier(),
);

// ============================================================================
// ERROR STATE
// ============================================================================

class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);

  void setError(String? error) {
    state = error;
  }

  void clear() {
    state = null;
  }
}

final errorProvider = StateNotifierProvider<ErrorNotifier, String?>(
  (ref) => ErrorNotifier(),
);

// ============================================================================
// FILTER STATE
// ============================================================================

class FilterNotifier extends StateNotifier<String?> {
  FilterNotifier() : super(null);

  void setCategory(String? category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, String?>(
  (ref) => FilterNotifier(),
);

// ============================================================================
// SEARCH STATE
// ============================================================================

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, String>(
  (ref) => SearchNotifier(),
);

// ============================================================================
// COMPUTED PROVIDERS (Combining multiple states)
// ============================================================================

/// Filtered overviews based on category
final filteredOverviewsProvider = FutureProvider<List<Overview>>((ref) async {
  final filter = ref.watch(filterProvider);

  if (filter == null || filter.isEmpty) {
    return ref.watch(overviewListProvider).when(
          data: (data) => data,
          loading: () => [],
          error: (_, __) => [],
        );
  }

  return ref.watch(overviewCategoryProvider(filter)).when(
        data: (data) => data,
        loading: () => [],
        error: (_, __) => [],
      );
});

/// Searched & filtered overviews
final searchedOverviewsProvider = FutureProvider<List<Overview>>((ref) async {
  final search = ref.watch(searchProvider);
  final filter = ref.watch(filterProvider);

  if (search.isEmpty && (filter == null || filter.isEmpty)) {
    return ref.watch(overviewListProvider).when(
          data: (data) => data,
          loading: () => [],
          error: (_, __) => [],
        );
  }

  if (search.isNotEmpty) {
    return ref.watch(overviewSearchProvider(search)).when(
          data: (data) {
            if (filter != null && filter.isNotEmpty) {
              return data.where((o) => o.category == filter).toList();
            }
            return data;
          },
          loading: () => [],
          error: (_, __) => [],
        );
  }

  return ref.watch(filteredOverviewsProvider).when(
        data: (data) => data,
        loading: () => [],
        error: (_, __) => [],
      );
});

/// Check if current user has already reviewed an overview
final hasUserReviewedProvider =
    FutureProvider.family<bool, String>((ref, overviewId) async {
  final userData = await ref.watch(userProfileProvider.future);
  if (userData == null) return false;

  final review = await ref.watch(
    expertReviewProvider((overviewId, userData.id)).future,
  );
  return review != null;
});

/// Get average review score for display
final averageReviewScoreProvider =
    FutureProvider.family<double, String>((ref, overviewId) async {
  final reviewsAsync = ref.watch(reviewsForOverviewProvider(overviewId));

  return reviewsAsync.when(
    data: (reviews) {
      if (reviews.isEmpty) return 0.0;
      final scores =
          reviews.map((r) => r.getAverageScore()).toList();
      return scores.reduce((a, b) => a + b) / scores.length;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
