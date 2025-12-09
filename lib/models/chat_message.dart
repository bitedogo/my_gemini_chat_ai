class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isTyping = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isTyping': isTyping,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    role: json['role'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isTyping: json['isTyping'] as bool? ?? false,
  );

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isTyping,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isTyping: isTyping ?? this.isTyping,
      );
}