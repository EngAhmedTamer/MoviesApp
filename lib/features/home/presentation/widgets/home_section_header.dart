import 'package:flutter/material.dart';
import 'package:movies_app/core/theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Decorative headings used on Home.
///
/// Shows the image if it exists, otherwise falls back to text.
class HomeScriptHeading extends StatelessWidget {
  const HomeScriptHeading(
    this.text, {
    this.fontSize = 48,
    required this.imagePath,
    super.key,
  });

  final String text;
  final double fontSize;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        imagePath,
        height: fontSize * 1.5,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              height: 1.05,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
