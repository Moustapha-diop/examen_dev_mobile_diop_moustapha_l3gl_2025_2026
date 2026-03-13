import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

/// Carte affichant une tâche
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key,
    required this.task,
    this.onTap});

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  String get _statusLabel {
    switch (task.status) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.done:
        return 'Terminé';
    }
  }

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  IconData get _priorityIcon {
    switch (task.priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.status == TaskStatus.done
                            ? AppColors.textDisable
                            : AppColors.textPrimary,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: _statusColor.withAlpha(80)),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
                Visibility(
                  visible: task.description != null && task.description!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      task.description ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Indicateur priorité
                  Icon(_priorityIcon, size: 14, color: _priorityColor),
                  const SizedBox(width: 3),
                  Text(
                    task.priority.name,
                    style: TextStyle(
                        fontSize: 12,
                        color: _priorityColor,
                        fontWeight: FontWeight.w500),
                  ),
                  // Date d'échéance
                  if (task.dueDate != null) ...[
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat('dd MMM', 'fr').format(task.dueDate!),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
