import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import 'package:intl/intl.dart';

class AddTodoForm extends StatefulWidget {
  final Function(Todo) onAdd;
  final String userId;

  const AddTodoForm({
    super.key,
    required this.onAdd,
    required this.userId,
  });

  @override
  State<AddTodoForm> createState() => _AddTodoFormState();
}

class _AddTodoFormState extends State<AddTodoForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  double? _latitude;
  double? _longitude;
  final _mapController = MapController();
  final _uuid = const Uuid();

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
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

  void _submitForm() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um título para a tarefa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newTodo = Todo(
      id: _uuid.v4(),
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
      scheduledFor: _selectedDateTime,
      latitude: _latitude,
      longitude: _longitude,
    );

    widget.onAdd(newTodo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          child: AppBar(
            title: const Text(
              'Nova Tarefa',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
            elevation: 0,
            automaticallyImplyLeading: false,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.blue,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.blue,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título da Tarefa',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição da Tarefa',
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
                    _selectedDateTime != null
                        ? 'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!)}'
                        : 'Selecionar Data e Hora',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _selectLocation,
                  icon: const Icon(Icons.location_on),
                  label: Text(_latitude != null
                      ? 'Alterar Localização'
                      : 'Adicionar Localização'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                if (_latitude != null && _longitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Latitude: ${_latitude!.toStringAsFixed(6)}\nLongitude: ${_longitude!.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SALVAR TAREFA'),
                ),
              ],
            ),
          ),
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
