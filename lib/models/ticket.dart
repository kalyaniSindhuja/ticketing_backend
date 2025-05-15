class Ticket {
  final int? id;
  final int userId;
  final String title;
  final String category;
  final String description;
  final String createdAt;
  final String status;

  Ticket({
    this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  factory Ticket.fromMap(Map<String, dynamic> map) => Ticket(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    title: map['title'] as String,
    category: map['category'] as String,
    description: map['description'] as String,
    createdAt: map['created_at'] as String,
    status: map['status'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'category': category,
    'description': description,
    'created_at': createdAt,
    'status': status,
  };
}
