import 'package:flutter/material.dart';
import '../utils/constants.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final Widget? actions;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.status,
    this.actions,
  });

  Color _statusColor() {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'inactive':
      case 'deactivated':
        return AppColors.textSecondary;
      case 'rejected':
      case 'deleted':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusBackgroundColor() {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return AppColors.successLight;
      case 'pending':
        return AppColors.warningLight;
      case 'inactive':
      case 'deactivated':
        return AppColors.divider;
      case 'rejected':
      case 'deleted':
        return AppColors.dangerLight;
      default:
        return AppColors.background;
    }
  }

  String _formattedStatus() {
    final value = status.trim();

    if (value.isEmpty) {
      return 'Unknown';
    }

    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim().isEmpty
                          ? 'Unnamed Teacher'
                          : name.trim(),
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email.trim().isEmpty
                          ? 'No email available'
                          : email.trim(),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusBackgroundColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formattedStatus(),
                  style: AppTextStyles.caption.copyWith(
                    color: _statusColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (actions != null) ...[
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              color: AppColors.divider,
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: actions!,
            ),
          ],
        ],
      ),
    );
  }
}