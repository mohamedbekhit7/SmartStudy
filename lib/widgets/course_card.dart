import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/course.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final int materialCount;
  final int assignmentCount;
  final int quizCount;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.materialCount,
    required this.assignmentCount,
    required this.quizCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdDate = DateFormat('MMM d, yyyy').format(course.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        borderRadius: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'course-${course.id}',
                  child: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryIndigo,
                          AppTheme.violet,
                          AppTheme.pink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.violet.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.primaryIndigo,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Professor ${course.instructorName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.darkText.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.violet,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              course.description.isEmpty
                  ? 'No description was added for this course yet.'
                  : course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.darkText.withValues(alpha: 0.62),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.qr_code_2_rounded,
                  label: course.code,
                  color: AppTheme.primaryIndigo,
                ),
                _InfoPill(
                  icon: Icons.calendar_month_rounded,
                  label: createdDate,
                  color: AppTheme.pink,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _CounterBox(
                  value: materialCount.toString(),
                  label: 'Materials',
                ),
                const SizedBox(width: 10),
                _CounterBox(value: assignmentCount.toString(), label: 'Tasks'),
                const SizedBox(width: 10),
                _CounterBox(value: quizCount.toString(), label: 'Quizzes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterBox extends StatelessWidget {
  final String value;
  final String label;

  const _CounterBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.62)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.darkText.withValues(alpha: 0.54),
                fontWeight: FontWeight.w800,
                fontSize: 10.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
