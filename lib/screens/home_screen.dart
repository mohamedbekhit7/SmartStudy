import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/course_item.dart';
import '../services/local_database.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import 'create_course_screen.dart';
import 'join_course_screen.dart';
import 'landing_screen.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _database = LocalDatabase();
  final _sessionService = SessionService();

  List<Course> _allCourses = [];
  List<CourseItem> _allItems = [];
  bool _isLoading = true;

  Timer? _titleTimer;
  int _titleColorIndex = 0;

  final List<Color> _titleColors = const [
    AppTheme.primaryIndigo,
    AppTheme.violet,
    AppTheme.pink,
    AppTheme.purple,
    AppTheme.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    _titleTimer = Timer.periodic(const Duration(milliseconds: 950), (_) {
      if (!mounted) return;
      setState(() {
        _titleColorIndex = (_titleColorIndex + 1) % _titleColors.length;
      });
    });
  }

  @override
  void dispose() {
    _titleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final courses = await _database.getCourses();
    final items = await _database.getCourseItems();

    if (!mounted) return;

    setState(() {
      _allCourses = courses;
      _allItems = items;
      _isLoading = false;
    });
  }

  List<Course> get _visibleCourses {
    if (widget.currentUser.isInstructor) {
      return _allCourses
          .where((course) => course.instructorId == widget.currentUser.id)
          .toList();
    }

    return _allCourses
        .where((course) => course.studentIds.contains(widget.currentUser.id))
        .toList();
  }

  int _countItems(String courseId, CourseItemType type) {
    return _allItems
        .where((item) => item.courseId == courseId && item.type == type)
        .length;
  }

  Future<void> _logout() async {
    await _sessionService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  Future<void> _openMainAction() async {
    if (widget.currentUser.isInstructor) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateCourseScreen(currentUser: widget.currentUser),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => JoinCourseScreen(currentUser: widget.currentUser),
        ),
      );
    }

    await _loadData();
  }

  void _openCourse(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CourseDetailScreen(currentUser: widget.currentUser, course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCourses = _visibleCourses;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openMainAction,
        backgroundColor: AppTheme.primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(
          widget.currentUser.isInstructor
              ? Icons.add_rounded
              : Icons.qr_code_scanner_rounded,
        ),
        label: Text(
          widget.currentUser.isInstructor ? 'Create Course' : 'Join Course',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 22),
                        _buildWelcomeCard(),
                        const SizedBox(height: 22),
                        _buildSectionHeader(visibleCourses.length),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (visibleCourses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
                      child: Center(
                        child: EmptyState(
                          icon: widget.currentUser.isInstructor
                              ? Icons.add_business_rounded
                              : Icons.school_outlined,
                          title: widget.currentUser.isInstructor
                              ? 'No created courses yet'
                              : 'No registered courses yet',
                          message: widget.currentUser.isInstructor
                              ? 'Tap the floating button to create your first SmartStudy course.'
                              : 'Tap the floating button to join a course using its class code and password.',
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course = visibleCourses[index];

                        return CourseCard(
                          course: course,
                          materialCount: _countItems(
                            course.id,
                            CourseItemType.material,
                          ),
                          assignmentCount: _countItems(
                            course.id,
                            CourseItemType.assignment,
                          ),
                          quizCount: _countItems(
                            course.id,
                            CourseItemType.quiz,
                          ),
                          onTap: () => _openCourse(course),
                        );
                      }, childCount: visibleCourses.length),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          style: TextStyle(
            color: _titleColors[_titleColorIndex],
            fontSize: 31,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
          child: const Text('SmartStudy'),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _logout,
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.68),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppTheme.primaryIndigo,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    final isInstructor = widget.currentUser.isInstructor;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            height: 66,
            width: 66,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isInstructor
                    ? const [AppTheme.primaryIndigo, AppTheme.violet]
                    : const [AppTheme.pink, AppTheme.violet],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.violet.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              isInstructor ? Icons.co_present_rounded : Icons.menu_book_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.currentUser.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryIndigo,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isInstructor
                      ? 'Create courses, post materials and guide your class.'
                      : 'Join courses, follow materials and complete activities.',
                  style: TextStyle(
                    color: AppTheme.darkText.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    fontSize: 12.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    final title = widget.currentUser.isInstructor
        ? 'Created Courses'
        : 'Registered Courses';

    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
            fontSize: 21,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(width: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.primaryIndigo,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
