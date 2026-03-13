import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isAuthor;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    required this.isAuthor,
    this.onDelete,
  });

  /// Date relative : "il y a X minutes", "il y a X heures", "hier", ou date formatée
  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return "à l'instant";
    } else if (diff.inMinutes < 60) {
      return 'il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'il y a ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'hier';
    } else if (diff.inDays < 7) {
      return 'il y a ${diff.inDays} jours';
    } else {
      return '${date.day} ${_monthName(date.month)}';
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'jan', 'fév', 'mar', 'avr',
      'mai', 'juin', 'juil', 'aoû', 'sep',
      'oct', 'nov', 'déc'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar — première lettre du nom
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: Text(
              comment.userName.isNotEmpty
                  ? comment.userName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom + date + bouton supprimer
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeDate(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    // Bouton supprimer — seulement si auteur
                    Visibility(
                      visible: isAuthor,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.textDisable,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Contenu du commentaire
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}