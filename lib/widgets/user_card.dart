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

  Color getStatusColor() {
    switch (status) {
      case "active":
        return AppColors.active;
      case "pending":
        return AppColors.pending;
      case "inactive":
        return AppColors.inactive;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),

        // ✅ THIS FIXES YOUR TEXT BREAKING ISSUE
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),

            const SizedBox(width: 12),

            // TEXT SECTION (EXPANDS PROPERLY)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppStyles.subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // STATUS + ACTIONS
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (actions != null) ...[
                  const SizedBox(height: 6),
                  actions!,
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}