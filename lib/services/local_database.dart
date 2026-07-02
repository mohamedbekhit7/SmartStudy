import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/course_item.dart';
import '../models/submission.dart';

class LocalDatabase {
  static const String _usersKey = 'smartstudy_users';
  static const String _coursesKey = 'smartstudy_courses';
  static const String _itemsKey = 'smartstudy_course_items';
  static const String _submissionsKey = 'smartstudy_assignment_submissions';
  static const String _quizResultsKey = 'smartstudy_quiz_results';

  Future<List<AppUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => AppUser.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  Future<void> addUser(AppUser user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  Future<AppUser?> findUserByName(String name) async {
    final users = await getUsers();
    final normalized = name.trim().toLowerCase();

    for (final user in users) {
      if (user.name.trim().toLowerCase() == normalized) {
        return user;
      }
    }

    return null;
  }

  Future<AppUser?> login(String name, String password) async {
    final users = await getUsers();
    final normalized = name.trim().toLowerCase();

    for (final user in users) {
      if (user.name.trim().toLowerCase() == normalized &&
          user.password == password) {
        return user;
      }
    }

    return null;
  }

  Future<List<Course>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_coursesKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => Course.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      courses.map((course) => course.toJson()).toList(),
    );
    await prefs.setString(_coursesKey, encoded);
  }

  Future<void> addCourse(Course course) async {
    final courses = await getCourses();
    courses.add(course);
    await saveCourses(courses);
  }

  Future<Course?> findCourseByCode(String code) async {
    final courses = await getCourses();
    final normalized = code.trim().toLowerCase();

    for (final course in courses) {
      if (course.code.trim().toLowerCase() == normalized) {
        return course;
      }
    }

    return null;
  }

  Future<void> enrollStudent({
    required String courseId,
    required String studentId,
  }) async {
    final courses = await getCourses();

    final updatedCourses = courses.map((course) {
      if (course.id != courseId) return course;

      if (course.studentIds.contains(studentId)) {
        return course;
      }

      return course.copyWith(
        studentIds: [...course.studentIds, studentId],
      );
    }).toList();

    await saveCourses(updatedCourses);
  }

  Future<List<CourseItem>> getCourseItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => CourseItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveCourseItems(List<CourseItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_itemsKey, encoded);
  }

  Future<void> addCourseItem(CourseItem item) async {
    final items = await getCourseItems();
    items.add(item);
    await saveCourseItems(items);
  }

  Future<List<CourseItem>> getItemsForCourse(String courseId) async {
    final items = await getCourseItems();
    return items.where((item) => item.courseId == courseId).toList();
  }

  Future<List<AssignmentSubmission>> getSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_submissionsKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map(
          (item) => AssignmentSubmission.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveSubmissions(List<AssignmentSubmission> submissions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      submissions.map((submission) => submission.toJson()).toList(),
    );
    await prefs.setString(_submissionsKey, encoded);
  }

  Future<void> addSubmission(AssignmentSubmission submission) async {
    final submissions = await getSubmissions();

    final withoutPrevious = submissions
        .where(
          (item) =>
              !(item.assignmentId == submission.assignmentId &&
                  item.studentId == submission.studentId),
        )
        .toList();

    withoutPrevious.add(submission);
    await saveSubmissions(withoutPrevious);
  }

  Future<List<QuizResult>> getQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quizResultsKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => QuizResult.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveQuizResults(List<QuizResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(results.map((result) => result.toJson()).toList());
    await prefs.setString(_quizResultsKey, encoded);
  }

  Future<void> addQuizResult(QuizResult result) async {
    final results = await getQuizResults();

    final withoutPrevious = results
        .where(
          (item) =>
              !(item.quizId == result.quizId &&
                  item.studentId == result.studentId),
        )
        .toList();

    withoutPrevious.add(result);
    await saveQuizResults(withoutPrevious);
  }
}