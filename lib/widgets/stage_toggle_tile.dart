import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stage_model.dart';
import '../theme/app_colors.dart';

class StageToggleTile extends StatelessWidget {
  final StageModel stage;
  final StageResultState state;
  final VoidCallback onTap;

  const StageToggleTile({
    super.key,
    required this.stage,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDobleG = stage.category == StageCategory.dobleG;

    // Colores y diseño según el estado actual
    Color btnBgColor;
    Color btnTextColor;
    Color btnBorderColor;
    IconData btnIcon;
    String btnText;

    switch (state) {
      case StageResultState.yes:
        btnBgColor = AppColors.statusYesBg;
        btnTextColor = AppColors.statusYes;
        btnBorderColor = AppColors.statusYes.withOpacity(0.4);
        btnIcon = Icons.check_circle_rounded;
        btnText = 'Sí';
        break;
      case StageResultState.no:
        btnBgColor = AppColors.statusNoBg;
        btnTextColor = AppColors.statusNo;
        btnBorderColor = AppColors.statusNo.withOpacity(0.4);
        btnIcon = Icons.cancel_rounded;
        btnText = 'No';
        break;
      case StageResultState.unobserved:
        btnBgColor = AppColors.surfaceSubtle;
        btnTextColor = AppColors.statusUnobserved;
        btnBorderColor = AppColors.cardBorder;
        btnIcon = Icons.remove_circle_outline_rounded;
        btnText = 'Sin observar';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state == StageResultState.yes
              ? AppColors.statusYes.withOpacity(0.3)
              : (state == StageResultState.no
                  ? AppColors.statusNo.withOpacity(0.3)
                  : AppColors.cardBorder),
          width: state != StageResultState.unobserved ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Badge de Categoría (Doble G o Embudo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDobleG ? AppColors.navy : AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isDobleG ? 'DOBLE G' : 'EMBUDO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Título de la etapa y meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              stage.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (stage.isKeyConversion) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Meta Venta',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (stage.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          stage.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Botón interactivo de Estado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: btnBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: btnBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(btnIcon, size: 14, color: btnTextColor),
                      const SizedBox(width: 5),
                      Text(
                        btnText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: btnTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
