import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class DashboardTab extends StatelessWidget {
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final String userName;

  const DashboardTab({
    super.key,
    required this.projectProvider,
    required this.taskProvider,
    required this.userName,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([projectProvider, taskProvider]),
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: () async {
            final user = StorageService.instance.getCurrentUser();
            if (user != null) {
              await projectProvider.loadProjects(user.id);
              await taskProvider.loadTasksByUser(user.id);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Message de bienvenue
              Text(
                '$_greeting, ${userName.split(' ').first} 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Voici un aperçu de vos activités',
                style:
                TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Statistiques
              _buildStatsRow(),
              const SizedBox(height: 24),

              // Projets récents
              const Text(
                'Projets récents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (projectProvider.projects.isEmpty)
                _buildEmptyState(
                    'Aucun projet', 'Créez votre premier projet !')
              else
                ...projectProvider.projects.take(3).map(
                      (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ProjectCard(
                      project: p,
                      taskCount: taskProvider.tasks
                          .where((t) => t.projectId == p.id)
                          .length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
///les stats
  Widget _buildStatsRow() {
    final counts = taskProvider.taskCountByStatus;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Projets',
            '${projectProvider.projectCount}',
            Icons.folder,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'À faire',
            '${counts[TaskStatus.todo] ?? 0}',
            Icons.radio_button_unchecked,
            AppColors.statusTodo,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'En cours',
            '${counts[TaskStatus.inProgress] ?? 0}',
            Icons.timelapse,
            AppColors.statusInProgress,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Terminé',
            '${counts[TaskStatus.done] ?? 0}',
            Icons.check_circle_outline,
            AppColors.statusDone,
          ),
        ),
      ],
    );
  }
//pour aficher une carte statistique
  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
//état vide
  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.folder_open_outlined,
                size: 48, color: AppColors.textDisable),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textDisable)),
          ],
        ),
      ),
    );
  }
}
