import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class StatProgressBar extends StatelessWidget {
  final String label;
  final double percentage; // 0 to 100
  final Color? barColor;
  final String? suffix;

  const StatProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    this.barColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final color = barColor ?? (percentage >= 50.0 ? AppColors.statusYes : AppColors.primary);
    final clamped = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              suffix ?? '${percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
