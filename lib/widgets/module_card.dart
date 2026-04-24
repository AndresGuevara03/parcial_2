import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE0E6EA),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    boxShadow: [
                      if (isDark)
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                    ],
                  ),
                  child: Icon(
                    icon, 
                    size: 32, 
                    color: AppTheme.primaryColor
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: 5),
                      Text(subtitle, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right_rounded, 
                  color: isDark ? Colors.white38 : AppTheme.textSecondary
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
