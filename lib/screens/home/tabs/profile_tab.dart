import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';

class ProfileTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = StorageService.instance.getCurrentUser();
    if (user == null) return const SizedBox();

    final avatarLetter = user.name.isNotEmpty
        ? user.name[0].toUpperCase()
        : 'U';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Avatar + nom
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary,
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Membre depuis ${DateFormat('MMMM yyyy', 'fr').format(user.createdAt)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textDisable),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Statistiques
        ListenableBuilder(
          listenable: Listenable.merge([projectProvider, taskProvider]),
          builder: (_, __) {
            return Row(
              children: [
                Expanded(
                    child: _statCard(
                        '${projectProvider.projectCount}',
                        'Projets',
                        Icons.folder,
                        AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                        '${taskProvider.totalCount}',
                        'Tâches',
                        Icons.checklist,
                        AppColors.secondary)),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        const Divider(),
        const SizedBox(height: 16),

        // Déconnexion
        CustomButton(
          text: 'Déconnexion',
          isOutlined: true,
          icon: Icons.logout,
          color: AppColors.error,
          onPressed: onLogout,
        ),
      ],
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
