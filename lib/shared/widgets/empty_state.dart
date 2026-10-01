import "package:flutter/material.dart";
import "../../core/theme.dart";

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title, required this.description, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 56, height: 56, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.primaryMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: Icon(icon, size: 26, color: AppColors.primary)),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}