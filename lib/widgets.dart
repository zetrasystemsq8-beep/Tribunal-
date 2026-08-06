// widgets.dart
// ============================================================================
// TRIBUNAL: Reusable UI Widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config.dart';
import 'models.dart';

// ============================================================================
// REVIEW CARD
// ============================================================================

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.expertName ?? 'Anonymous Expert',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (review.expertField != null)
                    Text(
                      review.expertField!,
                      style: const TextStyle(
                        color: AppColors.neutral600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Scores
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _ScoreBadge('Originality', review.originality),
              _ScoreBadge('Tech', review.technicalFeasibility),
              _ScoreBadge('Economic', review.economicFeasibility),
              _ScoreBadge('Ethics', review.ethics),
              _ScoreBadge('Legal', review.legalCompliance),
              _ScoreBadge('Social', review.socialImpact),
              _ScoreBadge('Environment', review.environmentalImpact),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recommendation
          if (review.recommendation != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _getRecommendationColor(review.recommendation!)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                review.recommendation!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getRecommendationColor(review.recommendation!),
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // Assessment Text
          if (review.strengths != null)
            _ReviewSection(title: 'Strengths', content: review.strengths!),
          if (review.weaknesses != null)
            _ReviewSection(title: 'Weaknesses', content: review.weaknesses!),
          if (review.risks != null && review.risks!.isNotEmpty)
            _ReviewSection(title: 'Risks', content: review.risks!),
          if (review.requiredChanges != null &&
              review.requiredChanges!.isNotEmpty)
            _ReviewSection(
              title: 'Required Changes',
              content: review.requiredChanges!,
            ),

          // Updated indicator
          if (review.updatedAt.isAfter(review.createdAt.add(Duration(seconds: 5))))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'Updated ${_formatDate(review.updatedAt)}',
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRecommendationColor(String rec) {
    switch (rec) {
      case 'Support':
        return AppColors.success;
      case 'Neutral':
        return AppColors.warning;
      case 'Oppose':
        return AppColors.error;
      case 'Needs Research':
        return AppColors.primary;
      default:
        return AppColors.neutral600;
    }
  }

  String _formatDate(DateTime date) {
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
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final String content;

  const _ReviewSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int? score;

  const _ScoreBadge(this.label, this.score);

  @override
  Widget build(BuildContext context) {
    final color = score == null
        ? AppColors.neutral300
        : _getScoreColor(score!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${score ?? 0}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

// ============================================================================
// SCORE DISPLAY (For Final Report)
// ============================================================================

class ScoreDisplay extends StatelessWidget {
  final AverageScores scores;

  const ScoreDisplay({Key? key, required this.scores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimensionNames = [
      'Originality',
      'Technical Feasibility',
      'Economic Feasibility',
      'Ethics',
      'Legal Compliance',
      'Social Impact',
      'Environmental Impact',
    ];

    final scoreValues = scores.asList();

    return Column(
      children: List.generate(
        dimensionNames.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dimensionNames[index],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${scoreValues[index].toStringAsFixed(1)}/100',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: LinearProgressIndicator(
                  value: scoreValues[index] / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(scoreValues[index].toInt()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

// ============================================================================
// CASE CARD (Browse List Item)
// ============================================================================

class CaseCard extends StatelessWidget {
  final Overview overview;

  const CaseCard({Key? key, required this.overview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/overview/${overview.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        overview.oneLiner,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.neutral400,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    overview.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatDate(overview.createdAt),
                  style: const TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

// ============================================================================
// LOADING SPINNER
// ============================================================================

class LoadingSpinner extends StatelessWidget {
  final String? message;

  const LoadingSpinner({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.neutral600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.neutral600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel ?? 'Take Action'),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR BANNER
// ============================================================================

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    Key? key,
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUCCESS BANNER
// ============================================================================

class SuccessBanner extends StatelessWidget {
  final String message;

  const SuccessBanner({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
