import 'package:flutter/material.dart';

/// Widget personalizado para AppBar do aplicativo
/// Mantém uma aparência consistente em todas as telas
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final bool centerTitle;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.elevation = 1.0,
    this.backgroundColor,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      leading: leading ?? (showBackButton 
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ) 
        : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
