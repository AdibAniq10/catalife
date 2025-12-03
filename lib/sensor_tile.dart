import 'package:flutter/material.dart';

class SensorTile extends StatelessWidget {
  final String title;
  final dynamic value;
  final String unit;
  final IconData icon;

  const SensorTile({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  Color _getStatusColor(String title, String displayValue) {
    if (title == "Water Quality") {
      if (displayValue == "NOT GOOD") return const Color(0xFFEF4444);
      if (displayValue == "GOOD") return const Color(0xFF10B981);
    }
    if (title == "Turbidity" && displayValue == "TURBID") {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF6366F1); // Default primary color
  }

  Color _getIconBgColor(String title, String displayValue) {
    if (title == "Water Quality") {
      if (displayValue == "NOT GOOD") return const Color(0xFFEF4444).withValues(alpha: 0.15);
      if (displayValue == "GOOD") return const Color(0xFF10B981).withValues(alpha: 0.15);
    }
    if (title == "Turbidity" && displayValue == "TURBID") {
      return const Color(0xFFF59E0B).withValues(alpha: 0.15);
    }
    return const Color(0xFF6366F1).withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final String displayValue = (value ?? '--').toString();
    final Color statusColor = _getStatusColor(title, displayValue);
    final Color iconBgColor = _getIconBgColor(title, displayValue);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> tileGradient = isDark
        ? [const Color(0xFF1E293B), const Color(0xFF1E293B).withValues(alpha: 0.8)]
        : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)];
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final Color titleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tileGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon with background
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: iconBgColor,
              ),
              child: Icon(
                icon,
                size: 28,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            // Title and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          displayValue,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? statusColor.withValues(alpha: 0.7)
                                  : statusColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}