import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class ProjectsTab extends StatelessWidget {
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const ProjectsTab({
    super.key,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, _) {
        if (projectProvider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary));
        }

        if (projectProvider.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open_outlined,
                    size: 64, color: AppColors.textDisable),
                const SizedBox(height: 16),
                const Text(
                  'Aucun projet',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Créez votre premier projet pour commencer',
                  style: TextStyle(color: AppColors.textDisable),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openCreate(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau projet'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projectProvider.projects.length,
          itemBuilder: (context, index) {
            final project = projectProvider.projects[index];
            final count = taskProvider.tasks
                .where((t) => t.projectId == project.id)
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProjectCard(
                project: project,
                taskCount: count,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(
                        project: project,
                        projectProvider: projectProvider,
                        taskProvider: taskProvider,
                      ),
                    ),
                  );
                },
                onEdit: () async {
                  final user = StorageService.instance.getCurrentUser();
                  if (user == null) return;
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectFormScreen(
                        userId: user.id,
                        project: project,
                      ),
                    ),
                  );
                  if (result == true) {
                    await projectProvider.loadProjects(user.id);
                  }
                },
                onDelete: () => _confirmDelete(context, project.id),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final user = StorageService.instance.getCurrentUser();
    if (user == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => ProjectFormScreen(userId: user.id)),
    );
    if (result == true) {
      await projectProvider.loadProjects(user.id);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text(
            'Êtes-vous sûr ? Toutes les tâches seront supprimées.'),
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
    if (confirmed == true) {
      await projectProvider.deleteProject(projectId);
    }
  }
}
