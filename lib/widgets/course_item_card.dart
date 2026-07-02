import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/course_item.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class CourseItemCard extends StatelessWidget {
  final CourseItem item;
  final VoidCallback? onTap;

  const CourseItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final createdDate = DateFormat(
      'MMM d, yyyy - h:mm a',
    ).format(item.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(17),
        borderRadius: 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypePill(),
                  const SizedBox(height: 9),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.description.isEmpty
                        ? _fallbackDescription()
                        : item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      fontSize: 12.8,
                    ),
                  ),
                  if (item.hasFile) ...[
                    const SizedBox(height: 10),
                    _buildFileRow(),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: AppTheme.darkText.withValues(alpha: 0.44),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Created: $createdDate',
                          style: TextStyle(
                            color: AppTheme.darkText.withValues(alpha: 0.48),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.dueDate.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.timer_rounded,
                          size: 15,
                          color: AppTheme.pink,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Due: ${item.dueDate}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.pink,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.violet,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_file_rounded,
            color: AppTheme.primaryIndigo,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w800,
                fontSize: 11.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final IconData icon;
    final List<Color> colors;

    switch (item.type) {
      case CourseItemType.material:
        icon = Icons.menu_book_rounded;
        colors = const [AppTheme.primaryIndigo, AppTheme.violet];
        break;
      case CourseItemType.assignment:
        icon = Icons.assignment_turned_in_rounded;
        colors = const [AppTheme.pink, AppTheme.violet];
        break;
      case CourseItemType.quiz:
        icon = Icons.quiz_rounded;
        colors = const [AppTheme.cyan, AppTheme.primaryIndigo];
        break;
    }

    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 25),
    );
  }

  Widget _buildTypePill() {
    final Color color;

    switch (item.type) {
      case CourseItemType.material:
        color = AppTheme.primaryIndigo;
        break;
      case CourseItemType.assignment:
        color = AppTheme.pink;
        break;
      case CourseItemType.quiz:
        color = AppTheme.violet;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        item.typeLabel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10.8,
        ),
      ),
    );
  }

  String _fallbackDescription() {
    switch (item.type) {
      case CourseItemType.material:
        return 'Lecture material has been posted for this course.';
      case CourseItemType.assignment:
        return 'Assignment instructions are ready for students.';
      case CourseItemType.quiz:
        return 'Quiz is ready for students to complete.';
    }
  }
}
