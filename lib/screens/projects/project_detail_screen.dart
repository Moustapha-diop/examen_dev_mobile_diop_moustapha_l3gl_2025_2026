import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _project;
  late TaskProvider _localTaskProvider;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _localTaskProvider = TaskProvider();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await _localTaskProvider.loadTasks(_project.id);
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text(
            'Toutes les tâches seront supprimées. Confirmer ?'),
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
      await widget.projectProvider.deleteProject(_project.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectColor = Color(_project.color);

    return Scaffold(
      body: ListenableBuilder(
        listenable: _localTaskProvider,
        builder: (context, _) {
          final counts = _localTaskProvider.taskCountByStatus;

          return CustomScrollView(
            slivers: [
              // En-tête coloré
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: projectColor,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _project.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  background: Container(
                    color: projectColor,
                    padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                    alignment: Alignment.bottomLeft,
                    child: _project.description != null
                        ? Text(
                      _project.description!,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                        : null,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      final user = StorageService.instance.getCurrentUser();
                      if (user == null) return;
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectFormScreen(
                            userId: user.id,
                            project: _project,
                          ),
                        ),
                      );
                      if (result == true) {
                        final updated =
                            (await widget.projectProvider.projects
                                .where((p) => p.id == _project.id)
                                .toList())
                                .firstOrNull;
                        if (updated != null) {
                          setState(() => _project = updated);
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _deleteProject,
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips statuts
                      Wrap(
                        spacing: 8,
                        children: TaskStatus.values.map((s) {
                          final count = counts[s] ?? 0;
                          final color = _statusColor(s);
                          return Chip(
                            label: Text(
                              '${_statusLabel(s)}: $count',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: color.withAlpha(20),
                            side: BorderSide(color: color.withAlpha(80)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tâches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des tâches
              if (_localTaskProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                )
              else if (_localTaskProvider.tasks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.checklist_outlined,
                            size: 48, color: AppColors.textDisable),
                        const SizedBox(height: 12),
                        const Text('Aucune tâche',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Ajoutez une tâche avec le bouton +',
                            style:
                            TextStyle(color: AppColors.textDisable)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        final task = _localTaskProvider.tasks[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(
                            task: task,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(
                                    task: task,
                                    taskProvider: _localTaskProvider,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: _localTaskProvider.tasks.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = StorageService.instance.getCurrentUser();
          if (user == null) return;
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(
                projectId: _project.id,
                userId: user.id,
              ),
            ),
          );
          if (result == true) await _loadTasks();
        },
        backgroundColor: projectColor,
        child: const Icon(Icons.add, color: Colors.white),
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
}
