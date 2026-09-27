import "package:flutter/material.dart";
import "../../models/vault_item.dart";
import "../../core/theme.dart";

class VaultItemCard extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onTap;

  const VaultItemCard({super.key, required this.item, required this.onTap});

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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description_outlined, color: AppColors.primary)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    if (item.expirationDate != null)
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(_statusText(), style: TextStyle(fontSize: 13, color: _statusColor())),
                        ],
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
