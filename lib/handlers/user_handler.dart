import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:shelf/shelf.dart';

import '../services/user_service.dart';
import '../models/user.dart';

final db = sqlite3.open('tickets.db');

class UserHandler {
  final UserService userService;

  UserHandler(this.userService);

  // Create a new user
  Future<Response> createUser(Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);
    final user = User(
      name: data['name'],
      email: data['email'],
      password: data['password'],
      role: data['role'],
    );
    userService.createUser(user);
    return Response.ok(
      jsonEncode({'message': 'User created'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Validate user credentials and generate JWT
  Future<Response> validate(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final email = data['email'] as String?;
      final password = data['password'] as String?;
      final role = data['role'] as String?;

      if (email == null || password == null || role == null) {
        return Response.badRequest(
          body: jsonEncode({
            'message': 'Missing required fields: email, password, or role',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = await userService.getUserByEmail(email);

      if (user == null) {
        return Response.unauthorized(
          jsonEncode({'message': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (user.password != password) {
        return Response.unauthorized(
          jsonEncode({'message': 'Incorrect password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (user.role != role) {
        return Response.unauthorized(
          jsonEncode({'message': 'Invalid role'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final jwt = JWT({'id': user.id, 'email': user.email, 'role': user.role});
      final token = jwt.sign(
        SecretKey('your-secret-key'), // Use secure key in production
        expiresIn: Duration(hours: 1),
      );

      return Response.ok(
        jsonEncode({'message': 'Authentication successful', 'token': token}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'message': 'Invalid request format',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // JWT Verification & Role-Based Access

  Future<Response> roleBasedDashboardHandler(Request request) async {
    final authHeader = request.headers['Authorization'];

    print('Authorization header: $authHeader');

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.forbidden(
        jsonEncode({'message': 'Missing or invalid Authorization header'}),
      );
    }

    final token = authHeader.substring(7); // Extract token

    try {
      final jwt = JWT.verify(token, SecretKey('your-secret-key'));
      final role = jwt.payload['role'];
      final email = jwt.payload['email'];

      return Response.ok(
        jsonEncode({
          'message': 'Welcome to $role Dashboard',
          'email': email,
          'role': role,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.unauthorized(
        jsonEncode({
          'message': 'Invalid or expired token',
          'error': e.toString(),
        }),
      );
    }
  }

  // Get all users
  Response getAllUsers(Request request) {
    final users = userService.getAllUsers();
    final usersJson = users.map((user) => user.toMap()).toList();
    return Response.ok(
      jsonEncode(usersJson),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Get a user by ID
  Response getUserById(Request request, String id) {
    try {
      final userId = int.parse(id);
      final user = userService.getUserById(userId);

      if (user != null) {
        return Response.ok(
          jsonEncode(user.toMap()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid user ID', 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Update user
  Future<Response> updateUser(Request request, String id) async {
    try {
      final userId = int.parse(id);
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final updatedUser = User(
        id: userId,
        name: data['name'],
        email: data['email'],
        password: data['password'],
        role: data['role'],
      );

      final success = userService.updateUser(updatedUser);

      if (success) {
        return Response.ok(
          jsonEncode({'message': 'User updated'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'User not found'}),
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

  // Delete user
  Response deleteUser(Request request, String id) {
    try {
      final userId = int.parse(id);
      final success = userService.deleteUser(userId);

      if (success) {
        return Response.ok(
          jsonEncode({'message': 'User deleted'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'message': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'message': 'Invalid user ID', 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

// Separate AuthController (if needed in the future)

class AuthController {
  final UserService userService;

  AuthController(this.userService);

  Future<Response> validate(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      // Extract email, password, and role from the request body
      final email = data['email'];
      final password = data['password'];
      final role =
          data['role']; // Assuming 'role' is passed as part of the request body

      // Validate user credentials
      final user = userService.getUserByEmailPasswordAndRole(
        email,
        password,
        role,
      );

      if (user != null) {
        // Login successful
        return Response.ok(
          jsonEncode({'message': 'Login successful', 'user': user.toJson()}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        // Invalid credentials
        return Response.forbidden('Invalid email, password, or role');
      }
    } catch (e) {
      // Internal server error
      return Response.internalServerError(
        body: 'An error occurred during login.',
      );
    }
  }
}
