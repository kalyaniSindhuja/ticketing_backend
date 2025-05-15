import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:sqlite3/sqlite3.dart';

Response roleBasedDashboardHandler(Request request, Database db) {
  final authHeader = request.headers['Authorization'];

  if (authHeader == null || !authHeader.startsWith('Bearer')) {
    return Response.forbidden(
      jsonEncode({'message': 'Missing or invalid Authorization header'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final token = authHeader.substring(7);

  try {
    final jwt = JWT.verify(token, SecretKey('your-secret-key'));
    final role = jwt.payload['role'];
    final email = jwt.payload['email'];

    if (role == 'admin') {
      final stats = getAdminTicketStats(db);
      return Response.ok(
        jsonEncode({'role': role, 'email': email, 'stats': stats}),
        headers: {'Content-Type': 'application/json'},
      );
    } else if (role == 'technician') {
      final openTickets = getTechnicianOpenTickets(db, email);
      return Response.ok(
        jsonEncode({'role': role, 'email': email, 'openTickets': openTickets}),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return Response.forbidden(
        jsonEncode({'message': 'Unauthorized role'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  } catch (e) {
    return Response.unauthorized(
      jsonEncode({
        'message': 'Invalid or expired token',
        'error': e.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Map<String, int> getAdminTicketStats(Database db) {
  final total =
      db.select("SELECT COUNT(*) AS count FROM tickets").first['count'] as int;
  final open =
      db
              .select(
                "SELECT COUNT(*) AS count FROM tickets WHERE status = 'open'",
              )
              .first['count']
          as int;
  final closed =
      db
              .select(
                "SELECT COUNT(*) AS count FROM tickets WHERE status = 'closed'",
              )
              .first['count']
          as int;

  return {'total': total, 'open': open, 'closed': closed};
}

List<Map<String, dynamic>> getTechnicianOpenTickets(Database db, String email) {
  final techUserResult = db.select('SELECT id FROM users WHERE email = ?', [
    email,
  ]);
  if (techUserResult.isEmpty) return [];

  final techId = techUserResult.first['id'];

  final results = db.select(
    '''
    SELECT tickets.*
    FROM tickets
    JOIN assignments ON tickets.id = assignments.ticket_id
    WHERE assignments.technician_id = ? AND tickets.status = 'open'
    ''',
    [techId],
  );

  return resultSetToMapList(results);
}

List<Map<String, dynamic>> resultSetToMapList(ResultSet results) {
  final columnNames = results.columnNames;

  return results.map((row) {
    final map = <String, dynamic>{};
    for (final column in columnNames) {
      map[column] = row[column];
    }
    return map;
  }).toList();
}
