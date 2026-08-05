// config.dart
import 'package:flutter/material.dart';

// Read from environment variables (set in GitHub Secrets via --dart-define)
const String SUPABASE_URL = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String SUPABASE_ANON_KEY = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

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
  static const String root = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String overview = '/overview/:id';
  static const String reviewForm = '/review/:overviewId/:expertId';
}

// ============================================================================
// UI CONSTANTS
// ============================================================================

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFB923C);
  static const Color error = Color(0xFFEF4444);
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
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
