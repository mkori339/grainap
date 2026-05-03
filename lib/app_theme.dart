import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const accent = Color(0xFF11C5BF);
  static const accentSoft = Color(0xFF83EFE9);
  static const highlight = Color(0xFFF2B544);
  static const success = Color(0xFF25D366);
  static const danger = Color(0xFFFF6B6B);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundSoft,
    required this.panel,
    required this.panelSoft,
    required this.panelMuted,
    required this.accent,
    required this.accentSoft,
    required this.highlight,
    required this.success,
    required this.danger,
  });

  final Color background;
  final Color backgroundSoft;
  final Color panel;
  final Color panelSoft;
  final Color panelMuted;
  final Color accent;
  final Color accentSoft;
  final Color highlight;
  final Color success;
  final Color danger;

  @override
  AppPalette copyWith({
    Color? background,
    Color? backgroundSoft,
    Color? panel,
    Color? panelSoft,
    Color? panelMuted,
    Color? accent,
    Color? accentSoft,
    Color? highlight,
    Color? success,
    Color? danger,
  }) {
    return AppPalette(
      background: background ?? this.background,
      backgroundSoft: backgroundSoft ?? this.backgroundSoft,
      panel: panel ?? this.panel,
      panelSoft: panelSoft ?? this.panelSoft,
      panelMuted: panelMuted ?? this.panelMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      highlight: highlight ?? this.highlight,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      background: Color.lerp(background, other.background, t) ?? background,
      backgroundSoft:
          Color.lerp(backgroundSoft, other.backgroundSoft, t) ?? backgroundSoft,
      panel: Color.lerp(panel, other.panel, t) ?? panel,
      panelSoft: Color.lerp(panelSoft, other.panelSoft, t) ?? panelSoft,
      panelMuted: Color.lerp(panelMuted, other.panelMuted, t) ?? panelMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      highlight: Color.lerp(highlight, other.highlight, t) ?? highlight,
      success: Color.lerp(success, other.success, t) ?? success,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}

class AppPalettes {
  static const AppPalette dark = AppPalette(
    background: Color(0xFF08121D),
    backgroundSoft: Color(0xFF0F2233),
    panel: Color(0xFF13293D),
    panelSoft: Color(0xFF1B3950),
    panelMuted: Color(0xFF224963),
    accent: AppColors.accent,
    accentSoft: AppColors.accentSoft,
    highlight: AppColors.highlight,
    success: AppColors.success,
    danger: AppColors.danger,
  );

  static const AppPalette light = AppPalette(
    background: Color(0xFFF5F1E7),
    backgroundSoft: Color(0xFFE8E0CF),
    panel: Color(0xFFFFFBF4),
    panelSoft: Color(0xFFF1E9DA),
    panelMuted: Color(0xFFE4D5BC),
    accent: Color(0xFF0E8E8D),
    accentSoft: Color(0xFF0E6A69),
    highlight: Color(0xFFC9870D),
    success: AppColors.success,
    danger: AppColors.danger,
  );
}

extension AppThemeContext on BuildContext {
  AppPalette get appPalette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalettes.dark;
}

class AppThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleThemeMode() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);
    final isDark = controller.themeMode == ThemeMode.dark;

    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: controller.toggleThemeMode,
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: color,
      ),
    );
  }
}

ThemeData buildAppTheme({required Brightness brightness}) {
  final palette =
      brightness == Brightness.dark ? AppPalettes.dark : AppPalettes.light;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
  );
  final foreground =
      brightness == Brightness.dark ? Colors.white : const Color(0xFF16222D);
  final mutedForeground =
      foreground.withValues(alpha: brightness == Brightness.dark ? 0.7 : 0.66);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: brightness,
  ).copyWith(
    primary: palette.accent,
    onPrimary:
        brightness == Brightness.dark ? palette.background : Colors.white,
    secondary: palette.highlight,
    onSecondary:
        brightness == Brightness.dark ? palette.background : Colors.white,
    surface: palette.panel,
    onSurface: foreground,
    error: palette.danger,
  );

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[palette],
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
      bodyColor: foreground,
      displayColor: foreground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: foreground,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 78,
      titleSpacing: 18,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: foreground,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: foreground),
      actionsIconTheme: IconThemeData(color: foreground),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.panelSoft
          .withValues(alpha: brightness == Brightness.dark ? 0.75 : 0.88),
      hintStyle: TextStyle(color: mutedForeground),
      labelStyle: TextStyle(color: mutedForeground),
      prefixIconColor: palette.accentSoft,
      suffixIconColor: mutedForeground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: foreground.withValues(
            alpha: brightness == Brightness.dark ? 0.08 : 0.1,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: foreground.withValues(
            alpha: brightness == Brightness.dark ? 0.08 : 0.1,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: palette.accent, width: 1.4),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: palette.panelSoft,
      selectedColor: palette.accent
          .withValues(alpha: brightness == Brightness.dark ? 0.18 : 0.14),
      labelStyle: TextStyle(color: foreground),
      secondaryLabelStyle: TextStyle(color: foreground),
      side: BorderSide(
        color: foreground.withValues(
          alpha: brightness == Brightness.dark ? 0.08 : 0.1,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    cardTheme: CardThemeData(
      color: palette.panel,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: BorderSide(
          color: foreground.withValues(
            alpha: brightness == Brightness.dark ? 0.16 : 0.18,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.accent,
      foregroundColor: colorScheme.onPrimary,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: foreground.withValues(
            alpha: brightness == Brightness.dark ? 0.06 : 0.04),
        disabledBackgroundColor: foreground.withValues(
            alpha: brightness == Brightness.dark ? 0.04 : 0.03),
        hoverColor: foreground.withValues(
            alpha: brightness == Brightness.dark ? 0.08 : 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: TextStyle(color: foreground),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      labelColor: foreground,
      unselectedLabelColor: foreground.withValues(alpha: 0.7),
      labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
      ),
      indicator: BoxDecoration(
        color: foreground.withValues(
          alpha: brightness == Brightness.dark ? 0.08 : 0.05,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: foreground.withValues(alpha: 0.08),
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.panelSoft,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentTextStyle: TextStyle(color: foreground),
    ),
    dividerColor: foreground.withValues(alpha: 0.08),
  );
}
