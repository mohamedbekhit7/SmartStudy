import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'local_database.dart';

class SessionService {
  static const String _currentUserIdKey = 'smartstudy_current_user_id';

  final LocalDatabase _database = LocalDatabase();

  Future<void> saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, user.id);
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserIdKey);

    if (userId == null || userId.isEmpty) return null;

    final users = await _database.getUsers();

    for (final user in users) {
      if (user.id == userId) return user;
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
  }

  Future<bool> hasActiveSession() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
