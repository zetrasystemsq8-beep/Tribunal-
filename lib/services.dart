// services.dart
// ============================================================================
// TRIBUNAL: Business Logic & Supabase Integration
// ============================================================================

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'models.dart';

final supabase = Supabase.instance.client;

// ============================================================================
// AUTH SERVICE
// ============================================================================

class AuthService {
  String? get lastInternalEmail => supabase.auth.currentUser?.email;

  /// Sign up with ZetraMail and password
  Future<UserProfile> signUp({
    required String zetramail,
    required String password,
    required String username,
  }) async {
    try {
      final resolveResult = await supabase.rpc('resolve_login_email', params: {
        'p_identifier': zetramail,
      });

      if (resolveResult == null) {
        throw Exception('ZetraMail resolution failed');
      }

      final internalEmail = resolveResult as String;

      final authResponse = await supabase.auth.signUp(
        email: internalEmail,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Sign up failed');
      }

      await supabase.from(TABLE_PROFILES).insert({
        'id': authResponse.user!.id,
        'zetramail': zetramail,
        'username': username,
        'verified': false,
      });

      return UserProfile(
        id: authResponse.user!.id,
        zetramail: zetramail,
        username: username,
        verified: false,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      throw Exception('Auth error: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with ZetraMail and password
  /// Returns user on success, then requires OTP verification
  Future<UserProfile> signIn({
    required String zetramail,
    required String password,
  }) async {
    try {
      final resolveResult = await supabase.rpc('resolve_login_email', params: {
        'p_identifier': zetramail,
      });

      if (resolveResult == null) {
        throw Exception('ZetraMail not found');
      }

      final internalEmail = resolveResult as String;

      final authResponse = await supabase.auth.signInWithPassword(
        email: internalEmail,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login failed');
      }

      await _requestOtp();

      final profileData = await supabase
          .from(TABLE_PROFILES)
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserProfile.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }
  
if (authResponse.user == null) {
        throw Exception('Login failed');
      }

      // Reset OTP status on every new login — a prior session's
      // verified flag must never carry over and silently skip
      // verification for a fresh sign-in.
      await supabase.auth.updateUser(
        UserAttributes(data: {'trib_otp_verified': false}),
      );

      await _requestOtp();
  /// Request OTP code — scoped to this app via p_app_name,
  /// works off the current auth session
  Future<void> _requestOtp() async {
    try {
      await supabase.rpc('request_otp', params: {
        'p_app_name': 'tribunal',
      });
    } catch (e) {
      throw Exception('OTP request failed: $e');
    }
  }

  /// Resend OTP for the current session
  Future<void> resendOtp() async {
    if (lastInternalEmail == null) {
      throw Exception('No active session. Please sign in again.');
    }
    await _requestOtp();
  }

  /// Verify OTP code and mark user as fully logged in.
  /// verify_otp works off the current session — only needs the code.
  Future<bool> verifyOtp({
    required String otpCode,
  }) async {
    try {
      final result = await supabase.rpc('verify_otp', params: {
        'p_code': otpCode,
      });

      if (result == true) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          await supabase.auth.updateUser(
            UserAttributes(
              data: {
                'trib_otp_verified': true,
              },
            ),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user
  Future<UserProfile?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final profileData = await supabase
          .from(TABLE_PROFILES)
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// OVERVIEW SERVICE (Crucible Reports)
// ============================================================================

class OverviewService {
  /// Fetch overview by ID from Supabase
  Future<Overview> fetchOverviewById(String overviewId) async {
    try {
      final data = await supabase
          .from(TABLE_OVERVIEWS)
          .select()
          .eq('id', overviewId)
          .single();

      return Overview.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception(ErrorMessages.overviewNotFound);
      }
      throw Exception('Failed to fetch overview: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching overview: $e');
    }
  }

  /// Fetch all overviews (for browsing)
  Future<List<Overview>> fetchAllOverviews({int limit = 50, int offset = 0}) async {
    try {
      final data = await supabase
          .from(TABLE_OVERVIEWS)
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((item) => Overview.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch overviews: $e');
    }
  }

  /// Verify overview by content hash (prevents tampering)
  bool verifyOverviewHash(Overview overview) {
    try {
      final snapshotJson = overview.snapshotData.toString();
      final calculatedHash = sha256.convert(snapshotJson.codeUnits).toString();
      return calculatedHash == overview.contentHash;
    } catch (e) {
      return false;
    }
  }

  /// Verify an Overview before navigating the user to it.
  /// Overviews are written directly by Crucible into the same shared
  /// table Tribunal reads from — Tribunal never copies or inserts a
  /// row of its own. This method is SELECT-only: it validates the ID
  /// and content hash, then returns the Overview. Because it never
  /// writes anything, it can never leave behind a partial or orphaned
  /// record, no matter how the attempt fails.
  Future<Overview> importOverviewById(String overviewId) async {
    final overview = await fetchOverviewById(overviewId);

    if (!verifyOverviewHash(overview)) {
      throw Exception(ErrorMessages.hashMismatch);
    }

    return overview;
  }

  /// Search overviews by category
  Future<List<Overview>> searchByCategory(String category) async {
    try {
      final data = await supabase
          .from(TABLE_OVERVIEWS)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => Overview.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Search overviews by title/one-liner
  Future<List<Overview>> searchByKeyword(String keyword) async {
    try {
      final data = await supabase
          .from(TABLE_OVERVIEWS)
          .select()
          .or('title.ilike.%$keyword%,one_liner.ilike.%$keyword%')
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => Overview.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}

// ============================================================================
// REVIEW SERVICE
// ============================================================================

class ReviewService {
  /// Submit a new review
  Future<Review> submitReview(Review review) async {
    try {
      final existing = await supabase
          .from(TABLE_REVIEWS)
          .select()
          .eq('overview_id', review.overviewId)
          .eq('expert_id', review.expertId)
          .maybeSingle();

      if (existing != null) {
        throw Exception(ErrorMessages.duplicateReview);
      }

      if (review.originality == null ||
          review.technicalFeasibility == null ||
          review.economicFeasibility == null ||
          review.ethics == null ||
          review.legalCompliance == null ||
          review.socialImpact == null ||
          review.environmentalImpact == null) {
        throw Exception('All scores must be provided');
      }

      final data = await supabase
          .from(TABLE_REVIEWS)
          .insert(review.toInsertJson())
          .select()
          .single();

      return Review.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to submit review: ${e.message}');
    } catch (e) {
      throw Exception('Review submission failed: $e');
    }
  }

  /// Update existing review
  Future<Review> updateReview(Review review) async {
    try {
      final data = await supabase
          .from(TABLE_REVIEWS)
          .update(review.toInsertJson())
          .eq('id', review.id)
          .select()
          .single();

      return Review.fromJson(data);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update review: ${e.message}');
    } catch (e) {
      throw Exception('Review update failed: $e');
    }
  }

  /// Fetch all reviews for an overview
  Future<List<Review>> fetchReviewsForOverview(String overviewId) async {
    try {
      final data = await supabase
          .from(TABLE_REVIEWS)
          .select()
          .eq('overview_id', overviewId)
          .order('created_at', ascending: false);

      List<Review> reviews = [];
      for (final item in data) {
        final review = Review.fromJson(item as Map<String, dynamic>);
        final profile = await _fetchProfileForReview(review.expertId);
        reviews.add(review.copyWith(
          expertName: profile?.username,
          expertField: profile?.field,
          expertAvatar: profile?.avatarUrl,
        ));
      }
      return reviews;
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  /// Fetch expert's review for an overview
  Future<Review?> fetchExpertReview(
      String overviewId, String expertId) async {
    try {
      final data = await supabase
          .from(TABLE_REVIEWS)
          .select()
          .eq('overview_id', overviewId)
          .eq('expert_id', expertId)
          .maybeSingle();

      if (data == null) return null;

      final review = Review.fromJson(data);
      final profile = await _fetchProfileForReview(expertId);
      return review.copyWith(
        expertName: profile?.username,
        expertField: profile?.field,
        expertAvatar: profile?.avatarUrl,
      );
    } catch (e) {
      throw Exception('Failed to fetch review: $e');
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await supabase.from(TABLE_REVIEWS).delete().eq('id', reviewId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Get review count for overview
  Future<int> getReviewCount(String overviewId) async {
    try {
      final data = await supabase
          .from(TABLE_REVIEWS)
          .select('id')
          .eq('overview_id', overviewId);

      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Helper: Fetch profile for review author
  Future<UserProfile?> _fetchProfileForReview(String userId) async {
    try {
      final data = await supabase
          .from(TABLE_PROFILES)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// REPORT SERVICE (Final Consensus Report)
// ============================================================================

class ReportService {
  /// Generate final report from reviews
  Future<FinalReport> generateFinalReport(
    String overviewId,
    List<Review> reviews,
  ) async {
    try {
      if (reviews.length < 3) {
        throw Exception('Minimum 3 reviews required for final report');
      }

      final averageScores = _calculateAverageScores(reviews);
      final analysis = _analyzeReviewAgreement(reviews);
      final verdict = _determineVerdict(averageScores);
      final confidence = _determineConfidence(reviews, analysis);

      final report = FinalReport(
        id: const Uuid().v4(),
        overviewId: overviewId,
        executiveSummary: _generateExecutiveSummary(averageScores, verdict),
        averageScores: averageScores,
        areasOfAgreement: analysis['agreement'],
        areasOfDisagreement: analysis['disagreement'],
        minorityOpinions: analysis['minority'],
        majorityOpinion: analysis['majority'],
        confidenceLevel: confidence,
        remainingConcerns: _summarizeConcerns(reviews),
        recommendations: _generateRecommendations(reviews, verdict),
        finalVerdict: verdict,
        reviewCount: reviews.length,
        generatedAt: DateTime.now(),
      );

      await supabase.from(TABLE_FINAL_REPORTS).insert(report.toJson());

      return report;
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  /// Fetch final report for overview
  Future<FinalReport?> fetchFinalReport(String overviewId) async {
    try {
      final data = await supabase
          .from(TABLE_FINAL_REPORTS)
          .select()
          .eq('overview_id', overviewId)
          .maybeSingle();

      if (data == null) return null;
      return FinalReport.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  AverageScores _calculateAverageScores(List<Review> reviews) {
    double sumOriginality = 0;
    double sumTechnical = 0;
    double sumEconomic = 0;
    double sumEthics = 0;
    double sumLegal = 0;
    double sumSocial = 0;
    double sumEnvironmental = 0;

    for (final review in reviews) {
      sumOriginality += review.originality ?? 0;
      sumTechnical += review.technicalFeasibility ?? 0;
      sumEconomic += review.economicFeasibility ?? 0;
      sumEthics += review.ethics ?? 0;
      sumLegal += review.legalCompliance ?? 0;
      sumSocial += review.socialImpact ?? 0;
      sumEnvironmental += review.environmentalImpact ?? 0;
    }

    final count = reviews.length.toDouble();

    return AverageScores(
      originality: sumOriginality / count,
      technicalFeasibility: sumTechnical / count,
      economicFeasibility: sumEconomic / count,
      ethics: sumEthics / count,
      legalCompliance: sumLegal / count,
      socialImpact: sumSocial / count,
      environmentalImpact: sumEnvironmental / count,
    );
  }

  Map<String, String> _analyzeReviewAgreement(List<Review> reviews) {
    final recommendations = reviews.map((r) => r.recommendation).toList();
    final agreementCount =
        recommendations.where((r) => r == recommendations.first).length;
    final isUnanimous = agreementCount == recommendations.length;

    String agreement = 'Experts generally agree on the recommendation';
    if (isUnanimous) {
      agreement = 'All experts unanimously recommend: ${recommendations.first}';
    }

    String disagreement = '';
    if (!isUnanimous) {
      final unique = recommendations.toSet().toList();
      disagreement = 'Varying opinions: ${unique.join(", ")}';
    }

    return {
      'agreement': agreement,
      'disagreement': disagreement,
      'minority': _extractMinorityOpinions(reviews),
      'majority': recommendations.first ?? 'No consensus',
    };
  }

  String _extractMinorityOpinions(List<Review> reviews) {
    final recommendations = reviews.map((r) => r.recommendation).toList();
    final counts = <String, int>{};
    for (final rec in recommendations) {
      counts[rec ?? 'Unknown'] = (counts[rec ?? 'Unknown'] ?? 0) + 1;
    }

    final minorRecommendations =
        counts.entries.where((e) => e.value < (reviews.length / 2).ceil());
    if (minorRecommendations.isEmpty) return 'None';

    return minorRecommendations
        .map((e) => '${e.key} (${e.value} expert${e.value > 1 ? 's' : ''})')
        .join(', ');
  }

  String _determineVerdict(AverageScores scores) {
    final overall = scores.getOverallAverage();

    if (overall >= 80) return 'Expert Approved';
    if (overall >= 65) return 'Conditionally Approved';
    if (overall >= 50) return 'Needs More Research';
    if (overall >= 35) return 'Needs Major Revision';
    return 'Rejected';
  }

  String _determineConfidence(
      List<Review> reviews, Map<String, String> analysis) {
    final recommendations = reviews.map((r) => r.recommendation).toList();
    final unanimousCount =
        recommendations.where((r) => r == recommendations.first).length;
    final unanimousPercent = (unanimousCount / reviews.length) * 100;

    if (unanimousPercent >= 80) return 'High';
    if (unanimousPercent >= 50) return 'Medium';
    return 'Low';
  }

  String _generateExecutiveSummary(AverageScores scores, String verdict) {
    final overall = scores.getOverallAverage();
    return '$verdict - Overall average score: ${overall.toStringAsFixed(1)}/100. '
        'Originality: ${scores.originality.toStringAsFixed(1)}, '
        'Feasibility: ${scores.technicalFeasibility.toStringAsFixed(1)}, '
        'Ethics: ${scores.ethics.toStringAsFixed(1)}.';
  }

  String _summarizeConcerns(List<Review> reviews) {
    final concerns = reviews
        .where((r) => r.weaknesses != null && r.weaknesses!.isNotEmpty)
        .map((r) => r.weaknesses)
        .join(' | ');

    return concerns.isEmpty
        ? 'No major concerns raised by experts.'
        : concerns;
  }

  String _generateRecommendations(List<Review> reviews, String verdict) {
    final recommendations = reviews
        .where((r) => r.requiredChanges != null && r.requiredChanges!.isNotEmpty)
        .map((r) => r.requiredChanges)
        .join(' | ');

    if (recommendations.isEmpty) {
      return 'No specific changes required.';
    }
    return 'Required changes: $recommendations';
  }
}

// ============================================================================
// PROFILE SERVICE
// ============================================================================

class ProfileService {
  /// Update user profile
  Future<UserProfile> updateProfile({
    required String userId,
    String? username,
    String? field,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (field != null) updates['field'] = field;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final data = await supabase
          .from(TABLE_PROFILES)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Fetch user profile
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final data = await supabase
          .from(TABLE_PROFILES)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

// Simple UUID generator
class Uuid {
  const Uuid();

  String v4() {
    final random = DateTime.now().microsecond;
    return '${random.toRadixString(16)}-${random.toRadixString(16)}-${random.toRadixString(16)}-${random.toRadixString(16)}';
  }
}
