import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/todo.dart';
import 'package:intl/intl.dart';

class EditTodoDialog extends StatefulWidget {
  final Todo todo;
  final Function(String) onDelete;

  const EditTodoDialog({
    super.key,
    required this.todo,
    required this.onDelete,
  });

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _scheduledDateTime;
  late double? _latitude;
  late double? _longitude;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description);
    _scheduledDateTime = widget.todo.scheduledFor;
    _latitude = widget.todo.latitude;
    _longitude = widget.todo.longitude;
  }

  Future<void> _confirmDelete() async {
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
      if (!mounted) return;
      widget.onDelete(widget.todo.id);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_scheduledDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectLocation() async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      _latitude ?? -23.550520,
                      _longitude ?? -46.633308,
                    ),
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      Navigator.of(context).pop(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (_latitude != null && _longitude != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_latitude!, _longitude!),
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
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Tarefa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
              hintText: 'Adicione uma descrição (opcional)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _selectDateTime,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _scheduledDateTime != null
                  ? 'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(_scheduledDateTime!)}'
                  : 'Selecionar Data e Hora',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _selectLocation,
            icon: const Icon(Icons.location_on),
            label: Text(_latitude != null
                ? 'Alterar Localização'
                : 'Adicionar Localização'),
          ),
          if (_latitude != null && _longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Lat: ${_latitude!.toStringAsFixed(6)}\nLong: ${_longitude!.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _confirmDelete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Excluir'),
        ),
        TextButton(
          onPressed: () {
            final editedTodo = widget.todo.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              scheduledFor: _scheduledDateTime,
              latitude: _latitude,
              longitude: _longitude,
            );
            Navigator.of(context).pop(editedTodo);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
