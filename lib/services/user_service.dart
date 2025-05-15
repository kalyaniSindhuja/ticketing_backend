import 'package:sqlite3/sqlite3.dart';
import '../models/user.dart';
import '../database.dart';

class UserService {
  final Database db;
  UserService(this.db);

  User? getUserByEmailPasswordAndRole(
    String email,
    String password,
    String role,
  ) {
    final ResultSet result = db.select(
      'SELECT * FROM users WHERE email = ? AND password = ? AND role = ?',
      [email, password, role],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final ResultSet result = db.select('SELECT * FROM users WHERE email = ?', [
      email,
    ]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  void createUser(User user) {
    db.execute(
      'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
      [user.name, user.email, user.password, user.role],
    );
  }

  List<User> getAllUsers() {
    final ResultSet result = db.select('SELECT * FROM users');
    return result.map((row) => User.fromMap(row)).toList();
  }

  User? getUserById(int id) {
    final ResultSet result = db.select('SELECT * FROM users WHERE id = ?', [
      id,
    ]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  bool updateUser(User user) {
    final existing = db.select('SELECT id FROM users WHERE id = ?', [user.id]);
    if (existing.isEmpty) {
      return false;
    }

    db.execute(
      'UPDATE users SET name = ?, email = ?, password = ?, role = ? WHERE id = ?',
      [user.name, user.email, user.password, user.role, user.id],
    );
    return true;
  }

  bool deleteUser(int id) {
    // First, check if the user exists
    final result = db.select('SELECT id FROM users WHERE id = ?', [id]);

    if (result.isEmpty) {
      return false; // User doesn't exist
    }

    // Proceed with deletion if the user exists
    db.execute('DELETE FROM users WHERE id = ?', [id]);
    return true; // Return true indicating the user was deleted
  }
}
