// config.dart
// ============================================================================
// TRIBUNAL: Configuration, Constants, Routes
// ============================================================================

const String SUPABASE_URL = 'your_supabase_url_here';
const String SUPABASE_ANON_KEY = 'your_anon_key_here';

// ============================================================================
// API ENDPOINTS & TABLE NAMES
// ============================================================================

const String TABLE_OVERVIEWS = 'overviews';
const String TABLE_REVIEWS = 'reviews';
const String TABLE_FINAL_REPORTS = 'final_reports';
const String TABLE_PROFILES = 'profiles';

// ============================================================================
// APP ROUTES
// ============================================================================

class AppRoutes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String importModal = '/import';
  static const String overviewDetail = '/overview/:id';
  static const String reviewForm = '/review/:overviewId';
  static const String reviewConfirmation = '/review-confirmation/:overviewId';
  static const String finalReport = '/report/:overviewId';
}

// ============================================================================
// UI CONSTANTS
// ============================================================================

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E40AF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFFB923C);
  static const error = Color(0xFFEF4444);
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral700 = Color(0xFF374151);
  static const neutral800 = Color(0xFF1F2937);
  static const neutral900 = Color(0xFF111827);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
}

class AppShadows {
  static const sm = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const md = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const lg = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
}

// ============================================================================
// REVIEW FORM LABELS & OPTIONS
// ============================================================================

class ReviewDimensions {
  static const List<String> dimensions = [
    'Originality',
    'Technical Feasibility',
    'Economic Feasibility',
    'Ethics',
    'Legal Compliance',
    'Social Impact',
    'Environmental Impact',
  ];

  static const Map<String, String> dimensionKeys = {
    'Originality': 'originality',
    'Technical Feasibility': 'technical_feasibility',
    'Economic Feasibility': 'economic_feasibility',
    'Ethics': 'ethics',
    'Legal Compliance': 'legal_compliance',
    'Social Impact': 'social_impact',
    'Environmental Impact': 'environmental_impact',
  };

  static const List<String> recommendations = [
    'Support',
    'Neutral',
    'Oppose',
    'Needs Research',
  ];
}

// ============================================================================
// VERDICT DEFINITIONS
// ============================================================================

class VerdictDefinitions {
  static const Map<String, String> descriptions = {
    'Expert Approved':
        'Experts universally recommend proceeding with this idea.',
    'Conditionally Approved':
        'Experts support the idea with specific conditions or revisions.',
    'Needs More Research':
        'Experts require additional evidence or data before judgment.',
    'Needs Major Revision':
        'Experts identify fundamental issues requiring significant rework.',
    'Rejected': 'Experts recommend rejecting this idea based on critical flaws.',
  };

  static const Map<String, Color> verdictColors = {
    'Expert Approved': AppColors.success,
    'Conditionally Approved': AppColors.warning,
    'Needs More Research': AppColors.primary,
    'Needs Major Revision': AppColors.error,
    'Rejected': AppColors.error,
  };
}

// ============================================================================
// CATEGORIES
// ============================================================================

class IdeaCategories {
  static const List<String> all = [
    'Politics',
    'Constitution',
    'Education',
    'Economics',
    'Law',
    'AI',
    'Healthcare',
    'Agriculture',
    'Robotics',
    'Climate',
    'Physics',
    'Business',
  ];
}

// ============================================================================
// ERROR MESSAGES
// ============================================================================

class ErrorMessages {
  static const String invalidId = 'Invalid Overview ID format.';
  static const String overviewNotFound =
      'Crucible Overview not found. Check the ID and try again.';
  static const String hashMismatch =
      'Overview integrity check failed. Content may have been tampered with.';
  static const String alreadyImported = 'This Overview is already in Tribunal.';
  static const String networkError =
      'Network error. Check your connection and try again.';
  static const String unauthorizedReview = 'You must be logged in to review.';
  static const String duplicateReview =
      'You have already reviewed this idea. Edit your existing review instead.';
  static const String invalidScore = 'Score must be between 0 and 100.';
  static const String missingField = 'Please fill in all required fields.';
}

// ============================================================================
// SUCCESS MESSAGES
// ============================================================================

class SuccessMessages {
  static const String reviewSubmitted = 'Your review has been submitted.';
  static const String reviewUpdated = 'Your review has been updated.';
  static const String overviewImported =
      'Overview imported to Tribunal successfully.';
}

// ============================================================================
// VALIDATION CONSTANTS
// ============================================================================

class ValidationRules {
  static const int minAssessmentLength = 20;
  static const int maxAssessmentLength = 2000;
  static const int minRecommendationLength = 10;
  static const int maxRecommendationLength = 1000;
  static const int uuidLength = 36;
}

// ============================================================================
// API RESPONSE CODES
// ============================================================================

class ApiCodes {
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int serverError = 500;
}
