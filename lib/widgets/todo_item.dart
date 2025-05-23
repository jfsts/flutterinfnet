import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/todo.dart';
import 'edit_todo_dialog.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final Function(Todo) onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  Future<void> _showLocationMap(BuildContext context) async {
    if (todo.latitude == null || todo.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta tarefa não possui localização definida'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(todo.latitude!, todo.longitude!),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(todo.latitude!, todo.longitude!),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => EditTodoDialog(
        todo: todo,
        onDelete: onDelete,
      ),
    );

    if (result != null) {
      onEdit(result);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete(todo.id);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = todo.isOverdue;

    return Dismissible(
      key: Key(todo.id),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Container(
        decoration: isOverdue
            ? BoxDecoration(
                border: Border.all(color: Colors.red.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
                color: Colors.red.shade50,
              )
            : null,
        margin: isOverdue ? const EdgeInsets.symmetric(vertical: 2) : null,
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(todo.id),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: TextStyle(
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: isOverdue && !todo.isCompleted
                        ? Colors.red.shade700
                        : null,
                    fontWeight:
                        isOverdue && !todo.isCompleted ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (isOverdue && !todo.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'VENCIDA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data e hora de vencimento
              if (todo.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: isOverdue && !todo.isCompleted
                            ? Colors.red
                            : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Vence: ${todo.formattedDueDateTimeCompact}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue && !todo.isCompleted
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                            fontWeight: isOverdue && !todo.isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // Data de criação
              Text(
                'Criado em: ${todo.createdAt.day}/${todo.createdAt.month}/${todo.createdAt.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              // Descrição
              if (todo.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    todo.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // Localização
              if (todo.latitude != null && todo.longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Lat: ${todo.latitude!.toStringAsFixed(4)}, Long: ${todo.longitude!.toStringAsFixed(4)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.location_on, size: 20),
                onPressed: () => _showLocationMap(context),
                color: todo.latitude != null ? Colors.blue : Colors.grey,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditDialog(context),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () async {
                  final shouldDelete = await _confirmDelete(context);
                  if (shouldDelete) {
                    onDelete(todo.id);
                  }
                },
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
