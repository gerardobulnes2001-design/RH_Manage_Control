import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;
  final bool showSubtitle;
  final bool isDark;

  const BrandLogo({
    super.key,
    this.fontSize = 24,
    this.showSubtitle = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono / Símbolo Institucional
            Container(
              width: fontSize * 1.3,
              height: fontSize * 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: fontSize * 0.75,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Tipografía de Marca
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'LA GARCÍA',
                    style: GoogleFonts.outfit(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.12) : AppColors.navy,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Z A P A T E R Í A',
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize * 0.35,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
