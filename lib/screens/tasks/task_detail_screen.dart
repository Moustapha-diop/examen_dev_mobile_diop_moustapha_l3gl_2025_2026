import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/comment_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/widgets/cards/comment_card.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final TaskProvider taskProvider;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.taskProvider,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  late CommentProvider _commentProvider;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _commentProvider = CommentProvider();
    _commentProvider.loadComments(_task.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentProvider.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(TaskStatus status) async {
    await widget.taskProvider.updateTaskStatus(_task.id, status);
    setState(() => _task = _task.copyWith(status: status));
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr ?'),
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
      await widget.taskProvider.deleteTask(_task.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = StorageService.instance.getCurrentUser();
    if (user == null) return;

    await _commentProvider.addComment(
      taskId: _task.id,
      userId: user.id,
      userName: user.name,
      content: content,
    );

    // Vider le champ
    _commentController.clear();

    // Scroller vers le bas
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(_task.priority);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la tâche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final user = StorageService.instance.getCurrentUser();
              if (user == null) return;
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(
                    projectId: _task.projectId,
                    userId: user.id,
                    task: _task,
                  ),
                ),
              );
              if (result == true && mounted) Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Contenu principal scrollable =====
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    _task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Visibility(
                    visible: _task.description != null &&
                        _task.description!.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _task.description ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Changement de statut rapide
                  const Text(
                    'Statut',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskStatus.values.map((s) {
                      final selected = _task.status == s;
                      final color = _statusColor(s);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => _changeStatus(s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? color.withAlpha(30)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                  selected ? color : AppColors.border,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _statusLabel(s),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selected
                                        ? color
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Priorité
                  _infoRow(
                    Icons.flag_outlined,
                    'Priorité',
                    _priorityLabel(_task.priority),
                    priorityColor,
                  ),
                  const SizedBox(height: 12),

                  // Date d'échéance
                  Visibility(
                    visible: _task.dueDate != null,
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.calendar_today_outlined,
                          'Échéance',
                          _task.dueDate != null
                              ? '${_task.dueDate!.day}/${_task.dueDate!.month}/${_task.dueDate!.year}'
                              : '',
                          AppColors.textPrimary,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  _infoRow(
                    Icons.access_time_outlined,
                    'Créé le',
                    '${_task.createdAt.day}/${_task.createdAt.month}/${_task.createdAt.year}',
                    AppColors.textSecondary,
                  ),

                  // ===== Section Commentaires =====
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // En-tête commentaires
                  ListenableBuilder(
                    listenable: _commentProvider,
                    builder: (context, _) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Commentaires (${_commentProvider.commentCount})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Liste des commentaires
                  ListenableBuilder(
                    listenable: _commentProvider,
                    builder: (context, _) {
                      // Chargement
                      if (_commentProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        );
                      }

                      // Aucun commentaire
                      if (_commentProvider.comments.isEmpty) {
                        return Center(
                          child: Column(
                            children: const [
                              SizedBox(height: 16),
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 40,
                                color: AppColors.textDisable,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Aucun commentaire',
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                              Text(
                                'Soyez le premier à commenter !',
                                style: TextStyle(
                                  color: AppColors.textDisable,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        );
                      }

                      // Liste des commentaires
                      final user =
                      StorageService.instance.getCurrentUser();
                      return Column(
                        children: _commentProvider.comments.map((comment) {
                          return CommentCard(
                            comment: comment,
                            isAuthor: user?.id == comment.userId,
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Supprimer'),
                                  content: const Text(
                                      'Supprimer ce commentaire ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Supprimer',
                                        style: TextStyle(
                                            color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await _commentProvider
                                    .deleteComment(comment.id);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // Espace pour le TextField
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ===== TextField commentaire en bas =====
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: ListenableBuilder(
              listenable: _commentController,
              builder: (context, _) {
                final isEmpty =
                    _commentController.text.trim().isEmpty;
                return Row(
                  children: [
                    // Champ de texte
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Écrire un commentaire...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                            BorderSide(color: AppColors.border),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bouton envoi
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      child: IconButton(
                        onPressed: isEmpty ? null : _addComment,
                        icon: const Icon(Icons.send_rounded),
                        color: isEmpty
                            ? AppColors.textDisable
                            : AppColors.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: isEmpty
                              ? Colors.transparent
                              : AppColors.primary.withAlpha(20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text('$label : ',
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
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