import "package:flutter/material.dart";
import "../../models/vault_item.dart";
import "../../core/theme.dart";
import "../../core/category_icons.dart";

class VaultItemCard extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onTap;
  final int index;
  final String? categoryName;

  const VaultItemCard({super.key, required this.item, required this.onTap, this.index = 0, this.categoryName});

  Color _statusColor() {
    if (item.isExpired) return AppColors.danger;
    if (item.isExpiringSoon) return AppColors.warning;
    return AppColors.success;
  }

  String _statusText() {
    if (item.isExpired) return "Expire";
    if (item.isExpiringSoon) return "Expire bientot (${item.daysUntilExpiration}j)";
    if (item.expirationDate != null) return "Valide";
    return "Sans expiration";
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 400)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: Transform.translate(offset: Offset(0, (1 - value) * 12), child: child));
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: AppColors.gradientPrimary.scale(0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Icon(categoryIcon(categoryName), color: AppColors.primaryLight),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (categoryName != null) ...[
                            Text(categoryName!, style: Theme.of(context).textTheme.labelSmall),
                            if (item.expirationDate != null) const Text("  •  ", style: TextStyle(color: AppColors.textSecondary)),
                          ],
                          if (item.expirationDate != null) ...[
                            Container(width: 7, height: 7, decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(_statusText(), style: TextStyle(fontSize: 13, color: _statusColor(), fontWeight: FontWeight.w500)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodyMedium?.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
