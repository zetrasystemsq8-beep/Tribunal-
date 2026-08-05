// utils.dart
// ============================================================================
// TRIBUNAL: Utilities, Validators, Formatters
// ============================================================================

import 'package:crypto/crypto.dart';

// ============================================================================
// VALIDATORS
// ============================================================================

class Validators {
  /// Validate ZetraMail format
  static String? validateZetraMail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ZetraMail is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@zetramail\.com$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid ZetraMail address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Validate Overview ID format
  static String? validateOverviewId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Overview ID is required';
    }

    // UUID format: 8-4-4-4-12
    final uuidRegex = RegExp(
      r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(value.trim())) {
      return 'Please enter a valid Overview ID';
    }

    return null;
  }

  /// Validate text field (required)
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate text length
  static String? validateTextLength(
    String? value, {
    int minLength = 0,
    int maxLength = 10000,
    String fieldName = 'Text',
  }) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  /// Validate OTP code
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP code is required';
    }

    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must be exactly 6 digits';
    }

    return null;
  }

  /// Validate score (0-100)
  static String? validateScore(int? value) {
    if (value == null) {
      return 'Score is required';
    }

    if (value < 0 || value > 100) {
      return 'Score must be between 0 and 100';
    }

    return null;
  }
}

// ============================================================================
// FORMATTERS
// ============================================================================

class Formatters {
  /// Format DateTime to readable string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Format DateTime to full string
  static String formatDateFull(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format DateTime to time string
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format double to percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Format double to score
  static String formatScore(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}/100';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  /// Format text as heading
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Format list as readable string
  static String formatList(List<String> items, {String separator = ', '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    return '${items.sublist(0, items.length - 1).join(separator)} & ${items.last}';
  }
}

// ============================================================================
// HASH UTILITIES
// ============================================================================

class HashUtils {
  /// Generate SHA256 hash of string
  static String sha256(String input) {
    return sha256Digest(input.codeUnits);
  }

  /// Generate SHA256 hash of bytes
  static String sha256Digest(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Verify content hash
  static bool verifyHash(String content, String hash) {
    final calculatedHash = sha256(content);
    return calculatedHash == hash;
  }
}

// ============================================================================
// CONSTANTS
// ============================================================================

class ScoreConstants {
  static const List<int> scoreRanges = [0, 20, 40, 60, 80, 100];

  static String getScoreLabel(int score) {
    if (score < 20) return 'Poor';
    if (score < 40) return 'Fair';
    if (score < 60) return 'Adequate';
    if (score < 80) return 'Good';
    return 'Excellent';
  }
}

class TextConstants {
  static const String appName = 'Tribunal';
  static const String appTagline = 'Where validated ideas meet expert judgment';
  static const String appDescription =
      'Expert review platform for ideas that survived AI stress testing';
}

// ============================================================================
// ERROR HANDLING
// ============================================================================

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String message = 'Network error occurred'})
      : super(message: message, code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  AuthException({String message = 'Authentication failed'})
      : super(message: message, code: 'AUTH_ERROR');
}

class ValidationException extends AppException {
  ValidationException({String message = 'Validation failed'})
      : super(message: message, code: 'VALIDATION_ERROR');
}

class ServerException extends AppException {
  ServerException({String message = 'Server error occurred'})
      : super(message: message, code: 'SERVER_ERROR');
}

// ============================================================================
// ERROR PARSER
// ============================================================================

class ErrorParser {
  static String parseError(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Connection refused')) {
        return 'Could not connect to server';
      }
      if (message.contains('SocketException')) {
        return 'Network connection error';
      }
      if (message.contains('TimeoutException')) {
        return 'Request timed out';
      }
      return message.replaceFirst('Exception: ', '');
    }

    return 'An unexpected error occurred';
  }

  static bool isNetworkError(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('connection') ||
        message.contains('socket') ||
        message.contains('network') ||
        message.contains('timeout');
  }

  static bool isAuthError(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('auth') ||
        message.contains('login') ||
        message.contains('unauthorized');
  }
}

// ============================================================================
// LOGGER (Simple logging utility)
// ============================================================================

class AppLogger {
  static void debug(String message) {
    print('🔵 DEBUG: $message');
  }

  static void info(String message) {
    print('🟢 INFO: $message');
  }

  static void warning(String message) {
    print('🟡 WARNING: $message');
  }

  static void error(String message, {dynamic exception}) {
    print('🔴 ERROR: $message');
    if (exception != null) {
      print('   Exception: $exception');
    }
  }

  static void success(String message) {
    print('✅ SUCCESS: $message');
  }
}
