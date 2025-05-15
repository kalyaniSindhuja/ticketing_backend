import 'package:sqlite3/sqlite3.dart';

final db = sqlite3.open('tickets.db');

void initDb() {
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT,
      password TEXT,
      role TEXT
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS tickets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      title TEXT,
      category TEXT,
      description TEXT,
      created_at TEXT,
      status TEXT DEFAULT 'open'
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS assignments (
      ticket_id INTEGER,
      technician_id INTEGER,
      assigned_by INTEGER,
      assigned_at TEXT
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS ticket_updates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ticket_id INTEGER,
      update_text TEXT,
      updated_by INTEGER,
      timestamp TEXT
    );
  ''');
}
