class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
    role: map['role'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'role': role,
  };

  // toJson method to convert a User object to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role, // We generally don't include password for security reasons
    };
  }
}
