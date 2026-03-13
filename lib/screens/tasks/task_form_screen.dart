import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final String projectId;
  final String userId;
  final Task? task; // null = création

  const TaskFormScreen({
    super.key,
    required this.projectId,
    required this.userId,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskProvider = TaskProvider();

  bool _isLoading = false;
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final task = _isEditing
        ? widget.task!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
      updatedAt: DateTime.now(),
    )
        : Task(
      id: const Uuid().v4(),
      projectId: widget.projectId,
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
    );

    if (_isEditing) {
      await _taskProvider.updateTask(task);
    } else {
      await _taskProvider.createTask(task);
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && widget.task != null) {
      await _taskProvider.deleteTask(widget.task!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Titre',
                controller: _titleController,
                hint: 'Titre de la tâche',
                prefixIcon: Icons.title,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Le titre est requis';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description (optionnel)',
                controller: _descriptionController,
                hint: 'Décrivez la tâche...',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),

              // Sélecteur de statut
              const Text('Statut',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Row(
                children: TaskStatus.values.map((s) {
                  final selected = _status == s;
                  final color = _statusColor(s);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        child: OutlinedButton(
                          onPressed: () => setState(() => _status = s),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? color.withAlpha(30)
                                : Colors.transparent,
                            foregroundColor: selected
                                ? color
                                : AppColors.textSecondary,
                            side: BorderSide(
                              color: selected ? color : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _statusLabel(s),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Sélecteur de priorité
              const Text('Priorité',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((p) {
                  final selected = _priority == p;
                  final color = _priorityColor(p);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        child: OutlinedButton(
                          onPressed: () => setState(() => _priority = p),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? color.withAlpha(30)
                                : Colors.transparent,
                            foregroundColor: selected
                                ? color
                                : AppColors.textSecondary,
                            side: BorderSide(
                              color: selected ? color : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _priorityLabel(p),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Date d'échéance
              const Text('Date d\'échéance (optionnel)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? AppColors.textPrimary
                              : AppColors.textDisable,
                        ),
                      ),
                      const Spacer(),
                      Visibility(
                        visible: _dueDate != null,
                        child: GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: _isEditing ? 'Enregistrer' : 'Créer la tâche',
                isLoading: _isLoading,
                onPressed: _submit,
                icon: _isEditing ? Icons.save : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.done:
        return 'Terminé';
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'Basse';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Haute';
    }
  }
}
