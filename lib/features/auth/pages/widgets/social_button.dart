import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String? iconAsset;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? iconSize;

  const SocialButton({
    super.key,
    required this.text,
    this.iconAsset,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = backgroundColor ?? colors.surface;
    final Color border = borderColor ?? colors.outline.withOpacity(0.14);
    final Color txtColor = textColor ?? colors.onSurface;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: border, width: 1),
        backgroundColor: bgColor,
        foregroundColor: txtColor,
        elevation: 0,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAsset != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SvgPicture.asset(
                iconAsset!,
                height: iconSize,
                width: iconSize,
                colorFilter: ColorFilter.mode(txtColor, BlendMode.srcIn),
              ),
            ),
          if (icon != null && iconAsset == null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(icon, size: iconSize, color: txtColor),
            ),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: txtColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}