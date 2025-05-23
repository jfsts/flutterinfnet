import 'package:flutter/material.dart';

class Todo {
  String id;
  String userId;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  double? latitude;
  double? longitude;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.dueTime,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime != null
          ? {'hour': dueTime!.hour, 'minute': dueTime!.minute}
          : null,
      'latitude': latitude,
      'longitude': longitude,
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
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueTime: json['dueTime'] != null
          ? TimeOfDay(
              hour: json['dueTime']['hour'], minute: json['dueTime']['minute'])
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    double? latitude,
    double? longitude,
  }) {
    return Todo(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Método para verificar se a tarefa está atrasada
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;

    final now = DateTime.now();
    final dueDateTime = dueTime != null
        ? DateTime(dueDate!.year, dueDate!.month, dueDate!.day, dueTime!.hour,
            dueTime!.minute)
        : DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 23, 59);

    return now.isAfter(dueDateTime);
  }

  // Método para formatar data e hora de vencimento
  String get formattedDueDateTime {
    if (dueDate == null) return '';

    final day = dueDate!.day.toString().padLeft(2, '0');
    final month = dueDate!.month.toString().padLeft(2, '0');
    final year = dueDate!.year;

    String dateStr = '$day/$month/$year';

    if (dueTime != null) {
      final hour = dueTime!.hour.toString().padLeft(2, '0');
      final minute = dueTime!.minute.toString().padLeft(2, '0');
      dateStr += ' às $hour:$minute';
    }

    return dateStr;
  }

  // Método para exibição compacta da data/hora
  String get formattedDueDateTimeCompact {
    if (dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    String dateStr;
    if (dueDay == today) {
      dateStr = 'Hoje';
    } else if (dueDay == tomorrow) {
      dateStr = 'Amanhã';
    } else {
      final day = dueDate!.day.toString().padLeft(2, '0');
      final month = dueDate!.month.toString().padLeft(2, '0');
      dateStr = '$day/$month';
    }

    if (dueTime != null) {
      final hour = dueTime!.hour.toString().padLeft(2, '0');
      final minute = dueTime!.minute.toString().padLeft(2, '0');
      dateStr += ' $hour:$minute';
    }

    return dateStr;
  }
}
