import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/todo.dart';
import '../models/endereco.dart';
import '../services/location_service.dart';
import '../services/viacep_service.dart';
import '../services/firestore_todo_service.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cepController = TextEditingController();

  final _locationService = LocationService();
  final _viaCepService = ViaCepService();
  final _todoService = FirestoreTodoService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Position? _currentPosition;
  Endereco? _endereco;
  bool _isLoadingLocation = false;
  bool _isLoadingCep = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Localização capturada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao obter localização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    if (cep.trim().isEmpty) return;

    setState(() {
      _isLoadingCep = true;
      _endereco = null;
    });

    try {
      final endereco = await _viaCepService.buscarEnderecoPorCep(cep);
      setState(() {
        _endereco = endereco;
      });

      if (mounted) {
        if (endereco?.isValido == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('✅ Endereço encontrado: ${endereco!.enderecoFormatado}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ CEP não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao buscar CEP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingCep = false;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      DateTime? scheduledDateTime;
      if (_selectedDate != null && _selectedTime != null) {
        scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final todo = Todo(
        id: '',
        userId: '', // Será substituído pelo FirestoreTodoService
        title: _titleController.text,
        description: _descriptionController.text,
        isCompleted: false,
        createdAt: DateTime.now(),
        scheduledFor: scheduledDateTime,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        cep: _cepController.text.trim().isNotEmpty
            ? _cepController.text.trim()
            : null,
        endereco:
            _endereco?.isValido == true ? _endereco!.enderecoFormatado : null,
      );

      await _todoService.addTodo(todo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tarefa criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao salvar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Tarefa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // CEP
                      TextFormField(
                        controller: _cepController,
                        decoration: InputDecoration(
                          labelText: 'CEP (opcional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: _isLoadingCep
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () => _buscarEnderecoPorCep(
                                      _cepController.text),
                                ),
                          helperText:
                              'Digite o CEP para buscar o endereço automaticamente',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Buscar automaticamente quando CEP tiver 8 dígitos
                          final cepLimpo =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cepLimpo.length == 8) {
                            _buscarEnderecoPorCep(value);
                          }
                        },
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final cepLimpo =
                                value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (cepLimpo.length != 8) {
                              return 'CEP deve ter 8 dígitos';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Exibir endereço encontrado
                      if (_endereco != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _endereco!.isValido
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            border: Border.all(
                              color: _endereco!.isValido
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _endereco!.isValido
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _endereco!.isValido
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _endereco!.isValido
                                      ? _endereco!.enderecoFormatado
                                      : 'CEP não encontrado',
                                  style: TextStyle(
                                    color: _endereco!.isValido
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Data e Hora
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                            : 'Selecionar data',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _selectedTime != null
                                            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Selecionar hora',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Localização
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoadingLocation ? null : _getCurrentLocation,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            _currentPosition != null
                                ? 'Localização capturada ✓'
                                : 'Capturar localização atual',
                          ),
                        ),
                      ),

                      if (_currentPosition != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                                  'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Botão Salvar (sempre visível na parte inferior)
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Salvar Tarefa',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
