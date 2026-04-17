import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final String title;
  final String status;
  final bool isOnline;
  final IconData icon;

  const StatusIndicator({
    super.key,
    required this.title,
    required this.status,
    required this.isOnline,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isOnline ? AppTheme.successColor : AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.successColor : AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOnline ? AppTheme.successColor : AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

