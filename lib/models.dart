// models.dart
// ============================================================================
// TRIBUNAL: Data Models & Serialization
// ============================================================================

import 'package:flutter/foundation.dart';

// ============================================================================
// USER / PROFILE MODEL
// ============================================================================

class UserProfile {
  final String id;
  final String zetramail;
  final String? username;
  final bool verified;
  final String? avatarUrl;
  final String? field;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.zetramail,
    this.username,
    required this.verified,
    this.avatarUrl,
    this.field,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      zetramail: json['zetramail'] as String,
      username: json['username'] as String?,
      verified: json['verified'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      field: json['field'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zetramail': zetramail,
      'username': username,
      'verified': verified,
      'avatar_url': avatarUrl,
      'field': field,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? zetramail,
    String? username,
    bool? verified,
    String? avatarUrl,
    String? field,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      zetramail: zetramail ?? this.zetramail,
      username: username ?? this.username,
      verified: verified ?? this.verified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      field: field ?? this.field,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserProfile(id: $id, zetramail: $zetramail, field: $field)';
}

// ============================================================================
// OVERVIEW MODEL (Crucible Report)
// ============================================================================

class Overview {
  final String id;
  final String crucibleIdeaId;
  final String title;
  final String oneLiner;
  final String category;
  final String executiveSummary;
  final String fullIdeaContent;
  final Map<String, dynamic>? findings;
  final Map<String, dynamic>? arbiterReport;
  final Map<String, dynamic> snapshotData;
  final String contentHash;
  final String? ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Overview({
    required this.id,
    required this.crucibleIdeaId,
    required this.title,
    required this.oneLiner,
    required this.category,
    required this.executiveSummary,
    required this.fullIdeaContent,
    this.findings,
    this.arbiterReport,
    required this.snapshotData,
    required this.contentHash,
    this.ownerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      id: json['id'] as String,
      crucibleIdeaId: json['crucible_idea_id'] as String,
      title: json['title'] as String,
      oneLiner: json['one_liner'] as String,
      category: json['category'] as String,
      executiveSummary: json['executive_summary'] as String,
      fullIdeaContent: json['full_idea_content'] as String,
      findings: json['findings'] as Map<String, dynamic>?,
      arbiterReport: json['arbiter_report'] as Map<String, dynamic>?,
      snapshotData: json['snapshot_data'] as Map<String, dynamic>,
      contentHash: json['content_hash'] as String,
      ownerName: json['owner_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crucible_idea_id': crucibleIdeaId,
      'title': title,
      'one_liner': oneLiner,
      'category': category,
      'executive_summary': executiveSummary,
      'full_idea_content': fullIdeaContent,
      'findings': findings,
      'arbiter_report': arbiterReport,
      'snapshot_data': snapshotData,
      'content_hash': contentHash,
      'owner_name': ownerName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Overview(id: $id, title: $title, category: $category)';
}

// ============================================================================
// REVIEW MODEL
// ============================================================================

class Review {
  final String id;
  final String overviewId;
  final String expertId;
  final int? originality;
  final int? technicalFeasibility;
  final int? economicFeasibility;
  final int? ethics;
  final int? legalCompliance;
  final int? socialImpact;
  final int? environmentalImpact;
  final String? risks;
  final String? strengths;
  final String? weaknesses;
  final String? requiredChanges;
  final String? recommendation;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient data (not in DB, populated by services)
  final String? expertName;
  final String? expertField;
  final String? expertAvatar;

  Review({
    required this.id,
    required this.overviewId,
    required this.expertId,
    this.originality,
    this.technicalFeasibility,
    this.economicFeasibility,
    this.ethics,
    this.legalCompliance,
    this.socialImpact,
    this.environmentalImpact,
    this.risks,
    this.strengths,
    this.weaknesses,
    this.requiredChanges,
    this.recommendation,
    required this.createdAt,
    required this.updatedAt,
    this.expertName,
    this.expertField,
    this.expertAvatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      overviewId: json['overview_id'] as String,
      expertId: json['expert_id'] as String,
      originality: json['originality'] as int?,
      technicalFeasibility: json['technical_feasibility'] as int?,
      economicFeasibility: json['economic_feasibility'] as int?,
      ethics: json['ethics'] as int?,
      legalCompliance: json['legal_compliance'] as int?,
      socialImpact: json['social_impact'] as int?,
      environmentalImpact: json['environmental_impact'] as int?,
      risks: json['risks'] as String?,
      strengths: json['strengths'] as String?,
      weaknesses: json['weaknesses'] as String?,
      requiredChanges: json['required_changes'] as String?,
      recommendation: json['recommendation'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expertName: json['expert_name'] as String?,
      expertField: json['expert_field'] as String?,
      expertAvatar: json['expert_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'overview_id': overviewId,
      'expert_id': expertId,
      'originality': originality,
      'technical_feasibility': technicalFeasibility,
      'economic_feasibility': economicFeasibility,
      'ethics': ethics,
      'legal_compliance': legalCompliance,
      'social_impact': socialImpact,
      'environmental_impact': environmentalImpact,
      'risks': risks,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'required_changes': requiredChanges,
      'recommendation': recommendation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    // For Supabase insert, exclude id and timestamps
    return {
      'overview_id': overviewId,
      'expert_id': expertId,
      'originality': originality,
      'technical_feasibility': technicalFeasibility,
      'economic_feasibility': economicFeasibility,
      'ethics': ethics,
      'legal_compliance': legalCompliance,
      'social_impact': socialImpact,
      'environmental_impact': environmentalImpact,
      'risks': risks,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'required_changes': requiredChanges,
      'recommendation': recommendation,
    };
  }

  List<int> getScores() {
    return [
      originality ?? 0,
      technicalFeasibility ?? 0,
      economicFeasibility ?? 0,
      ethics ?? 0,
      legalCompliance ?? 0,
      socialImpact ?? 0,
      environmentalImpact ?? 0,
    ];
  }

  double getAverageScore() {
    final scores = getScores();
    final nonZeroScores = scores.where((s) => s > 0).toList();
    if (nonZeroScores.isEmpty) return 0;
    return nonZeroScores.reduce((a, b) => a + b) / nonZeroScores.length;
  }

  /// Validates that all required fields for a review submission are filled.
  bool isValid() {
    return originality != null &&
        technicalFeasibility != null &&
        economicFeasibility != null &&
        ethics != null &&
        legalCompliance != null &&
        socialImpact != null &&
        environmentalImpact != null &&
        (strengths?.isNotEmpty ?? false) &&
        (weaknesses?.isNotEmpty ?? false) &&
        (recommendation?.isNotEmpty ?? false);
  }

  Review copyWith({
    String? id,
    String? overviewId,
    String? expertId,
    int? originality,
    int? technicalFeasibility,
    int? economicFeasibility,
    int? ethics,
    int? legalCompliance,
    int? socialImpact,
    int? environmentalImpact,
    String? risks,
    String? strengths,
    String? weaknesses,
    String? requiredChanges,
    String? recommendation,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? expertName,
    String? expertField,
    String? expertAvatar,
  }) {
    return Review(
      id: id ?? this.id,
      overviewId: overviewId ?? this.overviewId,
      expertId: expertId ?? this.expertId,
      originality: originality ?? this.originality,
      technicalFeasibility: technicalFeasibility ?? this.technicalFeasibility,
      economicFeasibility: economicFeasibility ?? this.economicFeasibility,
      ethics: ethics ?? this.ethics,
      legalCompliance: legalCompliance ?? this.legalCompliance,
      socialImpact: socialImpact ?? this.socialImpact,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      risks: risks ?? this.risks,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      requiredChanges: requiredChanges ?? this.requiredChanges,
      recommendation: recommendation ?? this.recommendation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expertName: expertName ?? this.expertName,
      expertField: expertField ?? this.expertField,
      expertAvatar: expertAvatar ?? this.expertAvatar,
    );
  }

  @override
  String toString() =>
      'Review(id: $id, overviewId: $overviewId, expertId: $expertId, recommendation: $recommendation)';
}

// ============================================================================
// FINAL REPORT MODEL
// ============================================================================

class FinalReport {
  final String id;
  final String overviewId;
  final String executiveSummary;
  final AverageScores averageScores;
  final String? areasOfAgreement;
  final String? areasOfDisagreement;
  final String? minorityOpinions;
  final String? majorityOpinion;
  final String? confidenceLevel;
  final String? remainingConcerns;
  final String? recommendations;
  final String finalVerdict;
  final int reviewCount;
  final DateTime generatedAt;

  FinalReport({
    required this.id,
    required this.overviewId,
    required this.executiveSummary,
    required this.averageScores,
    this.areasOfAgreement,
    this.areasOfDisagreement,
    this.minorityOpinions,
    this.majorityOpinion,
    this.confidenceLevel,
    this.remainingConcerns,
    this.recommendations,
    required this.finalVerdict,
    required this.reviewCount,
    required this.generatedAt,
  });

  factory FinalReport.fromJson(Map<String, dynamic> json) {
    return FinalReport(
      id: json['id'] as String,
      overviewId: json['overview_id'] as String,
      executiveSummary: json['executive_summary'] as String,
      averageScores:
          AverageScores.fromJson(json['average_scores'] as Map<String, dynamic>),
      areasOfAgreement: json['areas_of_agreement'] as String?,
      areasOfDisagreement: json['areas_of_disagreement'] as String?,
      minorityOpinions: json['minority_opinions'] as String?,
      majorityOpinion: json['majority_opinion'] as String?,
      confidenceLevel: json['confidence_level'] as String?,
      remainingConcerns: json['remaining_concerns'] as String?,
      recommendations: json['recommendations'] as String?,
      finalVerdict: json['final_verdict'] as String,
      reviewCount: json['review_count'] as int,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'overview_id': overviewId,
      'executive_summary': executiveSummary,
      'average_scores': averageScores.toJson(),
      'areas_of_agreement': areasOfAgreement,
      'areas_of_disagreement': areasOfDisagreement,
      'minority_opinions': minorityOpinions,
      'majority_opinion': majorityOpinion,
      'confidence_level': confidenceLevel,
      'remaining_concerns': remainingConcerns,
      'recommendations': recommendations,
      'final_verdict': finalVerdict,
      'review_count': reviewCount,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'FinalReport(id: $id, overviewId: $overviewId, finalVerdict: $finalVerdict)';
}

// ============================================================================
// AVERAGE SCORES MODEL
// ============================================================================

class AverageScores {
  final double originality;
  final double technicalFeasibility;
  final double economicFeasibility;
  final double ethics;
  final double legalCompliance;
  final double socialImpact;
  final double environmentalImpact;

  AverageScores({
    required this.originality,
    required this.technicalFeasibility,
    required this.economicFeasibility,
    required this.ethics,
    required this.legalCompliance,
    required this.socialImpact,
    required this.environmentalImpact,
  });

  factory AverageScores.fromJson(Map<String, dynamic> json) {
    return AverageScores(
      originality: (json['originality'] as num?)?.toDouble() ?? 0.0,
      technicalFeasibility:
          (json['technical_feasibility'] as num?)?.toDouble() ?? 0.0,
      economicFeasibility:
          (json['economic_feasibility'] as num?)?.toDouble() ?? 0.0,
      ethics: (json['ethics'] as num?)?.toDouble() ?? 0.0,
      legalCompliance: (json['legal_compliance'] as num?)?.toDouble() ?? 0.0,
      socialImpact: (json['social_impact'] as num?)?.toDouble() ?? 0.0,
      environmentalImpact:
          (json['environmental_impact'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originality': originality,
      'technical_feasibility': technicalFeasibility,
      'economic_feasibility': economicFeasibility,
      'ethics': ethics,
      'legal_compliance': legalCompliance,
      'social_impact': socialImpact,
      'environmental_impact': environmentalImpact,
    };
  }

  List<double> asList() {
    return [
      originality,
      technicalFeasibility,
      economicFeasibility,
      ethics,
      legalCompliance,
      socialImpact,
      environmentalImpact,
    ];
  }

  double getOverallAverage() {
    final scores = asList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  @override
  String toString() =>
      'AverageScores(overall: ${getOverallAverage().toStringAsFixed(1)})';
}

// ============================================================================
// AUTH STATE MODEL
// ============================================================================

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? error;
  final bool otpVerified;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.otpVerified = false,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? error,
    bool? otpVerified,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }

  @override
  String toString() =>
      'AuthState(user: $user, isLoading: $isLoading, otpVerified: $otpVerified)';
}
