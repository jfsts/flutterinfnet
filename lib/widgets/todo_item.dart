import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/todo.dart';
import 'edit_todo_dialog.dart';
import 'package:intl/intl.dart';

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
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Localização da Tarefa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(todo.latitude!, todo.longitude!),
                      initialZoom: 15.0,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewPadding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              todo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              title: const Text('Editar Tarefa'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
            ),
            if (todo.latitude != null && todo.longitude != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.location_on, color: Colors.green),
                ),
                title: const Text('Ver no Mapa'),
                onTap: () {
                  Navigator.pop(context);
                  _showLocationMap(context);
                },
              ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text('Excluir Tarefa'),
              onTap: () async {
                Navigator.pop(context);
                final shouldDelete = await _confirmDelete(context);
                if (shouldDelete) {
                  onDelete(todo.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(todo.id),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) => onDelete(todo.id),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 32),
              SizedBox(height: 4),
              Text(
                'Excluir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showActionMenu(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => onToggle(todo.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: todo.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                        border: Border.all(
                          color: todo.isCompleted ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: todo.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                        ),

                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Info chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            // Data de criação
                            _buildInfoChip(
                              icon: Icons.schedule,
                              label:
                                  DateFormat('dd/MM/yy').format(todo.createdAt),
                              color: Colors.grey,
                            ),

                            // Data programada
                            if (todo.scheduledFor != null)
                              _buildInfoChip(
                                icon: Icons.event,
                                label: DateFormat('dd/MM HH:mm')
                                    .format(todo.scheduledFor!),
                                color: Colors.blue,
                              ),

                            // Endereço
                            if (todo.endereco != null &&
                                todo.endereco!.isNotEmpty)
                              _buildInfoChip(
                                icon: Icons.location_city,
                                label: _truncateText(todo.endereco!, 20),
                                color: Colors.green,
                              ),

                            // GPS
                            if (todo.latitude != null && todo.longitude != null)
                              _buildInfoChip(
                                icon: Icons.gps_fixed,
                                label: 'GPS',
                                color: Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
