import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class FinanceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  const FinanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    
    final resolvedPadding = padding == const EdgeInsets.all(18)
        ? EdgeInsets.all(18.r(context))
        : padding;

    final resolvedBorderRadius = BorderRadius.circular(16.r(context));

    final content = Container(
      margin: margin,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: resolvedBorderRadius,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 18.r(context),
            offset: Offset(0, 10.r(context)),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
        borderRadius: resolvedBorderRadius, onTap: onTap, child: content);
  }
}

class SplitTitle extends StatelessWidget {
  final String first;
  final String second;
  final Color color;
  final IconData? icon;
  final double size;

  const SplitTitle({
    super.key,
    required this.first,
    required this.second,
    required this.color,
    this.icon,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = size.r(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: titleSize * 0.8),
          SizedBox(width: 10.r(context)),
        ],
        Expanded(
          child: Text.rich(
            TextSpan(
              text: first,
              children: [
                TextSpan(text: second, style: TextStyle(color: color)),
              ],
            ),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: titleSize,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class GradientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const GradientActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final active = onPressed != null;
    return Opacity(
      opacity: active ? 1 : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r(context)),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.r(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r(context)),
            gradient: const LinearGradient(
              colors: [Color(0xFF7B22E8), Color(0xFF3D8DFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: active ? 0.18 : 0),
                blurRadius: 20.r(context),
                offset: Offset(0, 10.r(context)),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.r(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class FinanceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const FinanceTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scaledLabelSize = 12.r(context);
    final scaledInputSize = 13.r(context);
    final scaledRadius = 14.r(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceMono(
                color: AppColors.textPrimary,
                fontSize: scaledLabelSize)),
        SizedBox(height: 8.r(context)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: scaledInputSize,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaledRadius),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaledRadius),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaledRadius),
              borderSide: const BorderSide(color: AppColors.purple),
            ),
          ),
        ),
      ],
    );
  }
}

class FinanceSelectField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const FinanceSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scaledLabelSize = 12.r(context);
    final scaledInputSize = 13.r(context);
    final scaledRadius = 14.r(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceMono(
                color: AppColors.textPrimary,
                fontSize: scaledLabelSize)),
        SizedBox(height: 8.r(context)),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          validator: validator,
          onChanged: onChanged,
          dropdownColor: AppColors.darkCard,
          iconEnabledColor: AppColors.textSecondary,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: scaledInputSize,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
            filled: true,
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaledRadius),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaledRadius),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
          ),
        ),
      ],
    );
  }
}

class SourceBalanceCard extends StatelessWidget {
  final String label;
  final String maskedName;
  final String balance;
  final double width;

  const SourceBalanceCard({
    super.key,
    required this.label,
    required this.maskedName,
    required this.balance,
    this.width = 210,
  });

  @override
  Widget build(BuildContext context) {
    final scaledWidth = width.r(context);
    return SizedBox(
      width: scaledWidth,
      child: FinanceCard(
        padding: EdgeInsets.all(18.r(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.spaceMono(
                    color: AppColors.textSecondary, fontSize: 11.r(context))),
            SizedBox(height: 10.r(context)),
            Text(maskedName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18.r(context),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            SizedBox(height: 12.r(context)),
            Text('Current balance',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14.r(context))),
            Text(balance,
                style: TextStyle(
                    color: AppColors.green,
                    fontSize: 28.r(context),
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class EmptyFinanceState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyFinanceState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: EdgeInsets.all(28.r(context)),
      child: Column(
        children: [
          Icon(icon, size: 38.r(context), color: AppColors.textSecondary),
          SizedBox(height: 12.r(context)),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 20.r(context), fontWeight: FontWeight.w900)),
          SizedBox(height: 10.r(context)),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                  color: AppColors.textSecondary, fontSize: 12.r(context))),
        ],
      ),
    );
  }
}

class FinanceFooter extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const FinanceFooter({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final footerHeight = 66.r(context);
    final buttonSize = 54.r(context);
    final iconSize = 26.r(context);
    final topOffset = (footerHeight - buttonSize) / 2;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: footerHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r(context))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 22.r(context),
                    offset: Offset(0, -8.r(context)),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.r(context)),
              child: Row(
                children: [
                  _FooterButton(
                    icon: Icons.home_outlined,
                    active: activeIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  _FooterButton(
                    icon: Icons.settings_outlined,
                    active: activeIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                ],
              ),
            ),
            Positioned(
              top: topOffset,
              child: InkWell(
                borderRadius: BorderRadius.circular(buttonSize / 2),
                onTap: () => onTabSelected(1),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(buttonSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.35),
                        blurRadius: 24.r(context),
                        offset: Offset(0, 10.r(context)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: activeIndex == 1
                        ? AppColors.purpleLight
                        : Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 66.r(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: active ? AppColors.purple : AppColors.textSecondary,
                  size: 26.r(context)),
              if (active) ...[
                SizedBox(height: 4.r(context)),
                Container(
                  width: 6.r(context),
                  height: 6.r(context),
                  decoration: const BoxDecoration(
                      color: AppColors.purple, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FinanceNavigationRail extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const FinanceNavigationRail({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final railBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconSize = 26.r(context);
    final appState = context.watch<AppStateModel>();

    return Container(
      width: 76.r(context),
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            SizedBox(height: 20.r(context)),
            // Miniature Logo
            Container(
              width: 44.r(context),
              height: 44.r(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r(context)),
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.blue],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Icon(Icons.account_balance_wallet_outlined,
                  size: 22.r(context), color: Colors.white),
            ),
            const Spacer(),
            // Navigation Icons
            _RailButton(
              icon: Icons.home_outlined,
              active: activeIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            SizedBox(height: 24.r(context)),
            // Psychology FAB/Middle Button
            InkWell(
              borderRadius: BorderRadius.circular(22.r(context)),
              onTap: () => onTabSelected(1),
              child: Container(
                width: 46.r(context),
                height: 46.r(context),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(23.r(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.35),
                      blurRadius: 12.r(context),
                      offset: Offset(0, 4.r(context)),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  color: activeIndex == 1
                      ? AppColors.purpleLight
                      : Colors.white,
                  size: iconSize,
                ),
              ),
            ),
            SizedBox(height: 24.r(context)),
            _RailButton(
              icon: Icons.settings_outlined,
              active: activeIndex == 2,
              onTap: () => onTabSelected(2),
            ),
            const Spacer(),
            // Theme Toggle
            IconButton(
              icon: Icon(
                appState.themeMode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: AppColors.textSecondary,
                size: 22.r(context),
              ),
              onPressed: () {
                appState.setThemeMode(
                  appState.themeMode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light,
                );
              },
            ),
            SizedBox(height: 16.r(context)),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _RailButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r(context)),
      child: SizedBox(
        width: 50.r(context),
        height: 50.r(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon,
                color: active ? AppColors.purple : AppColors.textSecondary,
                size: 26.r(context)),
            if (active)
              Positioned(
                left: 0,
                top: 15.r(context),
                bottom: 15.r(context),
                child: Container(
                  width: 4.r(context),
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(2.r(context)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
