class Todo {
  String id;
  String userId;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? scheduledFor;
  double? latitude;
  double? longitude;
  String? cep;
  String? endereco;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.scheduledFor,
    this.latitude,
    this.longitude,
    this.cep,
    this.endereco,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'cep': cep,
      'endereco': endereco,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'])
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      cep: json['cep'],
      endereco: json['endereco'],
    );
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? scheduledFor,
    double? latitude,
    double? longitude,
    String? cep,
    String? endereco,
  }) {
    return Todo(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
    );
  }
}
