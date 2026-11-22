import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import 'currency_utils.dart';

class MdpTheme {
  static const Color canvas = Color(0xFF090B14);
  static const Color surface = Color(0xFF121626);
  static const Color surfaceElevated = Color(0xFF191F36);
  static const Color surfaceInput = Color(0xFF14192C);
  static const Color primary = Color(0xFF5B63F6);
  static const Color primaryDeep = Color(0xFF3B41E3);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static Color get hairline => Colors.white.withValues(alpha: 0.08);
  static Color get hairlineStrong => Colors.white.withValues(alpha: 0.14);

  static const TextStyle tabularNumber = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
      primary: primary,
      error: rose,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: hairline, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: hairline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceInput,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: rose, width: 1.2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: hairlineStrong),
        ),
      ),
    );
  }
}

class MdpCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double borderRadius;

  const MdpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? MdpTheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? MdpTheme.hairline),
    );

    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(padding: padding, decoration: decoration, child: child),
      ),
    );
  }
}

class MdpStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const MdpStatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  factory MdpStatusBadge.paid() => const MdpStatusBadge(
        label: 'Төлөгдсөн',
        color: MdpTheme.emerald,
        icon: Icons.check_circle_outline,
      );

  factory MdpStatusBadge.pending() => const MdpStatusBadge(
        label: 'Хүлээгдэж буй',
        color: MdpTheme.amber,
        icon: Icons.schedule_rounded,
      );

  factory MdpStatusBadge.success() => const MdpStatusBadge(
        label: 'Амжилттай',
        color: MdpTheme.emerald,
        icon: Icons.verified_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MdpLoadingButton extends StatefulWidget {
  final String label;
  final String loadingLabel;
  final IconData? icon;
  final Future<void> Function()? onPressed;
  final Color? backgroundColor;
  final double height;

  const MdpLoadingButton({
    super.key,
    required this.label,
    this.loadingLabel = 'Уншиж байна...',
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.height = 52,
  });

  @override
  State<MdpLoadingButton> createState() => _MdpLoadingButtonState();
}

class _MdpLoadingButtonState extends State<MdpLoadingButton> {
  bool _isBusy = false;

  Future<void> _handlePress() async {
    if (_isBusy || widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isBusy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? MdpTheme.primary;
    final disabled = _isBusy || widget.onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: FilledButton(
        onPressed: disabled ? null : _handlePress,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _isBusy
              ? Row(
                  key: const ValueKey('busy'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.loadingLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 19),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class MdpQuickAmountChips extends StatelessWidget {
  final TextEditingController controller;
  final List<int> amounts;
  final ValueChanged<int>? onSelected;

  const MdpQuickAmountChips({
    super.key,
    required this.controller,
    this.amounts = const [5000, 10000, 20000, 50000],
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentAmount = CurrencyUtils.parseMnt(controller.text).round();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((amount) {
        final isSelected = currentAmount == amount;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              final formatted =
                  CurrencyUtils.formatMnt(amount, withSymbol: false);
              controller.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
              onSelected?.call(amount);
            },
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? MdpTheme.primary.withValues(alpha: 0.22)
                    : MdpTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? MdpTheme.primary : MdpTheme.hairline,
                ),
              ),
              child: Text(
                CurrencyUtils.formatMnt(amount),
                style: MdpTheme.tabularNumber.copyWith(
                  color: isSelected ? MdpTheme.textPrimary : MdpTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MdpSegmentedBar<T> extends StatelessWidget {
  final T value;
  final List<({T id, String label})> items;
  final ValueChanged<T> onChanged;

  const MdpSegmentedBar({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MdpTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MdpTheme.hairline),
      ),
      child: Row(
        children: items.map((item) {
          final selected = item.id == value;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!selected) {
                  HapticFeedback.lightImpact();
                  onChanged(item.id);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? MdpTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : MdpTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MdpShimmerDashboard extends StatelessWidget {
  const MdpShimmerDashboard({super.key});

  Widget _box({
    required double height,
    double? width,
    double radius = 16,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: MdpTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF14192B),
      highlightColor: const Color(0xFF232B47),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(height: 16, width: 140, radius: 6),
            const SizedBox(height: 10),
            _box(height: 26, width: 220, radius: 8),
            const SizedBox(height: 20),
            _box(height: 184, width: double.infinity, radius: 24),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (_) => Column(
                  children: [
                    _box(height: 56, width: 56, radius: 18),
                    const SizedBox(height: 8),
                    _box(height: 12, width: 54, radius: 6),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            _box(height: 18, width: 170, radius: 6),
            const SizedBox(height: 12),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _box(height: 76, width: double.infinity, radius: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MdpEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MdpEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: MdpTheme.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: MdpTheme.hairline),
              ),
              child: Icon(icon, size: 32, color: MdpTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MdpTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MdpTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: MdpTheme.primary,
                  side: BorderSide(color: MdpTheme.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MdpFeedback {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF112622),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: MdpTheme.emerald.withValues(alpha: 0.45)),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: MdpTheme.emerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: MdpTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: MdpTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: MdpTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFF28131B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: MdpTheme.rose.withValues(alpha: 0.45)),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: MdpTheme.rose,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: MdpTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          action: onRetry == null
              ? null
              : SnackBarAction(
                  label: 'Дахин оролдох',
                  textColor: Colors.white,
                  onPressed: onRetry,
                ),
        ),
      );
  }
}
