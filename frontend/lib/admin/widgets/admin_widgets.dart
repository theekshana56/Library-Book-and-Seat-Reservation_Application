import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../debug_agent_log.dart';
import '../../theme/app_colors.dart';

class AdminPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  const AdminPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageBg,
    appBar: AppBar(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      titleSpacing: 18,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFFB8C7D5),
              ),
            ),
        ],
      ),
      actions: actions,
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        // #region agent log
        final inset = MediaQuery.viewInsetsOf(context).bottom;
        if (constraints.maxHeight == double.infinity || inset > 0) {
          agentDebugLog(
            location: 'admin_widgets.dart:AdminPageScaffold',
            message: 'scaffold body constraints',
            hypothesisId: 'C',
            data: {
              'title': title,
              'maxH': constraints.maxHeight,
              'maxW': constraints.maxWidth,
              'minH': constraints.minHeight,
              'viewInsetBottom': inset,
              'unboundedH': constraints.maxHeight == double.infinity,
            },
          );
        }
        // #endregion
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: child,
          ),
        );
      },
    ),
  );
}

class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class AdminSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  const AdminSectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
    ],
  );
}

class AdminField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final String? Function(String?)? validator;
  const AdminField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // #region agent log
    var controllerDisposed = false;
    try {
      controller.hasListeners;
    } catch (_) {
      controllerDisposed = true;
    }
    if (controllerDisposed) {
      agentDebugLog(
        location: 'admin_widgets.dart:AdminField',
        message: 'AdminField built with disposed controller',
        hypothesisId: 'B',
        data: {'label': label},
      );
    }
    // #endregion
    return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: obscureText ? 1 : maxLines,
    obscureText: obscureText,
    readOnly: readOnly,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE4EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDCE4EB)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      color: AppColors.textPrimary,
    ),
  );
  }
}

class AdminStatusPill extends StatelessWidget {
  final String status;
  const AdminStatusPill(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final waiting =
        normalized.contains('PENDING') || normalized == 'IN_PROGRESS';
    final rejected = normalized == 'REJECTED';
    final background = waiting
        ? const Color(0xFFFFF3CD)
        : rejected
        ? const Color(0xFFFDE2E2)
        : AppColors.mintBg;
    final foreground = waiting
        ? const Color(0xFF856404)
        : rejected
        ? const Color(0xFF9B2C2C)
        : AppColors.mintText;
    final label = normalized.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class AdminMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  const AdminMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => AdminCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AdminLoadingError extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  const AdminLoadingError({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }
    if (error == null) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.warning,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
