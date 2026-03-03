import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

class TasksTab extends StatelessWidget {
  final TaskProvider taskProvider;

  const TasksTab({super.key, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: taskProvider,
      builder: (context, _) {
        return Column(
          children: [
            _buildFilters(context),
            Expanded(
              child: taskProvider.isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary))
                  : taskProvider.tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, i) {
                  final task = taskProvider.tasks[i];
                  return Padding(
                    padding:
                    const EdgeInsets.only(bottom: 8),
                    child: TaskCard(
                      task: task,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TaskDetailScreen(
                                task: task,
                                taskProvider: taskProvider,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(
              context,
              label: 'Tous',
              selected: taskProvider.statusFilter == null &&
                  taskProvider.priorityFilter == null,
              onTap: () => taskProvider.clearFilters(),
            ),
            const SizedBox(width: 6),
            _filterChip(context,
                label: 'À faire',
                selected:
                taskProvider.statusFilter == TaskStatus.todo,
                onTap: () =>
                    taskProvider.setStatusFilter(TaskStatus.todo)),
            const SizedBox(width: 6),
            _filterChip(context,
                label: 'En cours',
                selected: taskProvider.statusFilter ==
                    TaskStatus.inProgress,
                onTap: () => taskProvider
                    .setStatusFilter(TaskStatus.inProgress)),
            const SizedBox(width: 6),
            _filterChip(context,
                label: 'Terminé',
                selected:
                taskProvider.statusFilter == TaskStatus.done,
                onTap: () =>
                    taskProvider.setStatusFilter(TaskStatus.done)),
            const SizedBox(width: 6),
            _filterChip(context,
                label: '🔴 Haute',
                selected: taskProvider.priorityFilter ==
                    TaskPriority.high,
                onTap: () => taskProvider
                    .setPriorityFilter(TaskPriority.high)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context,
      {required String label,
        required bool selected,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color:
            selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_outlined,
              size: 64, color: AppColors.textDisable),
          SizedBox(height: 16),
          Text('Aucune tâche',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('Ajoutez des tâches depuis un projet',
              style: TextStyle(color: AppColors.textDisable)),
        ],
      ),
    );
  }
}
