import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:ticketing_backend/database.dart' as dbLib;
import 'package:ticketing_backend/handlers/ticket_handler.dart';
import 'package:ticketing_backend/handlers/user_handler.dart';
import 'package:ticketing_backend/handlers/dashboard_handler.dart'; // make sure this file defines roleBasedDashboardHandler
import 'package:ticketing_backend/services/ticket_service.dart';
import 'package:ticketing_backend/services/user_service.dart';

void main() async {
  dbLib.initDb();
  final db = dbLib.db;

  final userService = UserService(db);
  final ticketService = TicketService(db);

  final userHandler = UserHandler(userService);
  final ticketHandler = TicketHandler(ticketService);
  final authController = AuthController(userService);

  final router = Router();

  // User routes
  router.post('/auth', userHandler.validate);
  router.post('/auth/login', authController.validate); // one login route only
  router.post('/users', userHandler.createUser);
  router.get('/users', userHandler.getAllUsers);
  router.get('/users/<id>', userHandler.getUserById);
  router.put('/users/<id>', userHandler.updateUser);
  router.delete('/users/<id>', userHandler.deleteUser);

  // Ticket routes
  router.post('/tickets', ticketHandler.createTicket);
  router.get('/tickets', ticketHandler.getAllTickets);
  router.get('/tickets/<id>', ticketHandler.getTicketById);
  // router.get('/tickets/user/<userid>', ticketHandler.getTicketsByUserId); // implement this only if needed
  router.put(
    '/tickets/<id>',
    ticketHandler.updateTicket,
  ); // fixed `/ticket` to `/tickets`
  router.delete('/tickets/<id>', ticketHandler.deleteTicket);

  // Ticket status routes
  router.get('/tickets/status', ticketHandler.getTicketsByStatus);
  router.get('/tickets/<id>/status', ticketHandler.getTicketStatusById);
  router.put('/tickets/<id>/status', ticketHandler.updateTicketStatus);
  router.put('/tickets/status', ticketHandler.updateTicketStatus);

  // Dashboard route (role-based)
  router.get('/dashboard', (Request req) => roleBasedDashboardHandler(req, db));

  // Start server
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
}
