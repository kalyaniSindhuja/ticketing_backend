import 'package:sqlite3/sqlite3.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

class TicketService {
  final Database db;

  TicketService(this.db);

  // Create a new ticket
  void createTicket(Ticket ticket) {
    db.execute(
      'INSERT INTO tickets (user_id, title, category, description, created_at) VALUES (?, ?, ?, ?, ?)',
      [
        ticket.userId,
        ticket.title,
        ticket.category,
        ticket.description,
        ticket.createdAt,
      ],
    );
  }

  // Get all tickets
  List<Ticket> getAllTickets() {
    final result = db.select('SELECT * FROM tickets');
    return result.map((row) => Ticket.fromMap(row)).toList();
  }

  // Get tickets by userId
  List<Ticket> getTicketsByUserId(int userId) {
    final result = db.select('SELECT * FROM tickets WHERE user_id = ?', [
      userId,
    ]);
    return result.map((row) => Ticket.fromMap(row)).toList();
  }

  // Get ticket by ID
  Ticket? getTicketById(int id) {
    final result = db.select('SELECT * FROM tickets WHERE id = ?', [id]);
    if (result.isNotEmpty) {
      return Ticket.fromMap(result.first);
    }
    return null;
  }

  // Update a ticket
  bool updateTicket(Ticket ticket) {
    try {
      db.execute(
        'UPDATE tickets SET title = ?, category = ?, description = ?, created_at = ? WHERE id = ?',
        [
          ticket.title,
          ticket.category,
          ticket.description,
          ticket.createdAt,
          ticket.id,
        ],
      );
      return true; // If no error occurs, the update is assumed to be successful
    } catch (e) {
      print('Error updating ticket: $e');
      return false;
    }
  }

  // Delete a ticket
  bool deleteTicket(int id) {
    try {
      db.execute('DELETE FROM tickets WHERE id = ?', [id]);
      return true; // If no error occurs, the delete is assumed to be successful
    } catch (e) {
      print('Error deleting ticket: $e');
      return false;
    }
  }

  // Get tickets by status
  List<Ticket> getTicketsByStatus(String status) {
    final result = db.select('SELECT * FROM tickets WHERE status = ?', [
      status,
    ]);
    return result.map((row) => Ticket.fromMap(row)).toList();
  }

  // Assign a ticket to a user
  bool assignTicketToUser(int ticketId, int userId) {
    try {
      db.execute('UPDATE tickets SET user_id = ? WHERE id = ?', [
        userId,
        ticketId,
      ]);
      return true; // If no error occurs, the assignment is assumed to be successful
    } catch (e) {
      print('Error assigning ticket to user: $e');
      return false;
    }
  }

  // Update ticket status

  bool updateTicketStatus(int id, String status) {
    final result = db.execute('UPDATE tickets SET status = ? WHERE id = ?', [
      status,
      id,
    ]);
    return db.getUpdatedRows() > 0;
  }

  // ✅ Define getAdminTicketStats()

  Map<String, dynamic> getAdminTicketStats() {
    final total =
        db.select('SELECT COUNT(*) AS count FROM tickets').first['count']
            as int;
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

    return {
      'totalTickets': total,
      'openTickets': open,
      'closedTickets': closed,
    };
  }

  // ✅ Define getTechnicianOpenTickets()
  List<Map<String, dynamic>> getTechnicianOpenTickets(String email) {
    final result = db.select(
      '''
    SELECT t.*
    FROM tickets t
    JOIN assignments a ON t.id = a.ticket_id
    JOIN users u ON a.technician_id = u.id
    WHERE u.email = ? AND t.status = 'open'
  ''',
      [email],
    );

    return result.map((row) => row).toList();
  }
}
