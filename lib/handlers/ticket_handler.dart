import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/ticket_service.dart';
import '../models/ticket.dart';

class TicketHandler {
  final TicketService ticketService;

  TicketHandler(this.ticketService);

  // Create a new ticket
  Future<Response> createTicket(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final ticket = Ticket(
        userId: data['user_id'],
        title: data['title'],
        category: data['category'],
        description: data['description'],
        status: data['status'],
        createdAt: DateTime.now().toIso8601String(),
      );

      // Call without await
      ticketService.createTicket(ticket);

      return Response.ok(
        jsonEncode({'message': 'Ticket created'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid request', 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Get all tickets

  // Get all tickets
  Response getAllTickets(Request request) {
    try {
      // Retrieve the Authorization header
      String? authorizationHeader = request.headers['Authorization'];

      // Check if Authorization header is present
      if (authorizationHeader == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Missing Authorization header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Extract the Bearer token from the Authorization header
      String? accessToken =
          authorizationHeader.startsWith('Bearer ')
              ? authorizationHeader.substring(7)
              : null;

      // If the token is not in the correct format
      if (accessToken == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Invalid Bearer token format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Here you can validate the token if necessary (e.g., decode it or check its validity)

      // Fetch all tickets from the ticket service
      final tickets = ticketService.getAllTickets();

      // If no tickets are found, return a message
      if (tickets.isEmpty) {
        return Response.ok(
          jsonEncode({'message': 'No tickets found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Convert the tickets to JSON
      final ticketsJson = tickets.map((ticket) => ticket.toMap()).toList();

      // Return the tickets as JSON
      return Response.ok(
        jsonEncode(ticketsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      // Handle any errors that occur
      print('Error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal Server Error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Get a ticket by ID
  Response getTicketById(Request request, String id) {
    try {
      final ticket = ticketService.getTicketById(int.parse(id));

      if (ticket != null) {
        return Response.ok(
          jsonEncode(ticket.toMap()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'Ticket not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'message': 'Invalid ticket ID',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Update ticket
  Future<Response> updateTicket(Request request, String id) async {
    try {
      final ticketId = int.parse(id);
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final updatedTicket = Ticket(
        id: ticketId,
        userId: data['user_id'],
        title: data['title'],
        category: data['category'],
        description: data['description'],
        status: data['status'],
        createdAt: DateTime.now().toIso8601String(),
      );

      final success = ticketService.updateTicket(updatedTicket);

      if (success) {
        return Response.ok(
          jsonEncode({'message': 'Ticket updated'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'Ticket not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid request', 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Delete ticket
  Response deleteTicket(Request request, String id) {
    try {
      final ticketId = int.parse(id);
      final success = ticketService.deleteTicket(ticketId);

      if (success) {
        return Response.ok(
          jsonEncode({'message': 'Ticket deleted'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'Ticket not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'message': 'Invalid ticket ID',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Get tickets by status
  Future<Response> getTicketsByStatus(Request request, String status) async {
    try {
      final tickets = ticketService.getTicketsByStatus(status);

      if (tickets.isNotEmpty) {
        return Response.ok(
          jsonEncode(tickets.map((ticket) => ticket.toMap()).toList()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'No tickets found for this status'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid request', 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Assign ticket to user
  Future<Response> assignTicketToUser(Request request, String id) async {
    try {
      final ticketId = int.parse(id);
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userId = data['user_id'];

      final success = ticketService.assignTicketToUser(ticketId, userId);

      if (success) {
        return Response.ok(
          jsonEncode({'message': 'Ticket assigned to user'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'Ticket not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid request', 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  //  update Ticket status

  Future<Response> updateTicketStatus(Request request, String id) async {
    try {
      final ticketId = int.parse(id);
      final body = await request.readAsString();
      final data = jsonDecode(body);

      if (data['status'] == null) {
        return Response.badRequest(
          body: jsonEncode({'message': 'Status is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updated = ticketService.updateTicketStatus(
        ticketId,
        data['status'],
      );

      if (updated) {
        return Response.ok(
          jsonEncode({'message': 'Ticket status updated'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'Ticket not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
  // getticketstatusbyId

  Future<Response> getTicketStatusById(Request request, String id) async {
    try {
      final ticketId = int.parse(id);
      final ticket = ticketService.getTicketById(ticketId);

      if (ticket != null) {
        return Response.ok(
          jsonEncode({'status': ticket.status}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'Ticket not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
