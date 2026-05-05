import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color Palette
// Source: design_system.md · "Dark Neon / Cyber-Academic"
// All values are const Color(0xAARRGGBB).
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Backgrounds (3-tier elevation system) ────────────────────────────────
  static const Color background = Color(0xFF050505); // App bg · #050505
  static const Color surface    = Color(0xFF171717); // Cards   · zinc-900
  static const Color navBar     = Color(0xFF0A0A0A); // Nav bar · #0a0a0a

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border         = Color(0xFF27272A); // zinc-800
  static const Color borderElevated = Color(0x803F3F46); // zinc-700/50

  // ── Accent: Neon Yellow (#FDE047 = Tailwind yellow-300) ──────────────────
  // The single accent operates as high-contrast punctuation — never decorative.
  static const Color accent        = Color(0xFFFDE047);
  static const Color accentGlow050 = Color(0x80FDE047); // rgba(253,224,71,0.50) — dots
  static const Color accentGlow040 = Color(0x66FDE047); // rgba(253,224,71,0.40) — icons
  static const Color accentGlow025 = Color(0x40FDE047); // rgba(253,224,71,0.25) — buttons
  static const Color accentGlow012 = Color(0x1FFDE047); // rgba(253,224,71,0.12) — toast shadow
  static const Color accentSubtle  = Color(0x1AFDE047); // yellow-300/10 — icon containers
  static const Color accentFrame   = Color(0x14FDE047); // rgba(253,224,71,0.08) — phone frame

  // Ambient top-light gradients (very low opacity — atmospheric only)
  static const Color accentAmbient        = Color(0x0AFDE047); // rgba(253,224,71,0.04)
  static const Color accentAmbientOffline = Color(0x05F59E0B); // rgba(245,158,11,0.02)

  // ── Text Hierarchy ────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA); // zinc-400
  static const Color textTertiary  = Color(0xFF71717A); // zinc-500

  // ── Semantic: Offline / Warning ───────────────────────────────────────────
  // amber-500 = #f59e0b · amber-400 = #fbbf24
  static const Color offlineBg     = Color(0x26F59E0B); // amber-500/15
  static const Color offlineBorder = Color(0x4DF59E0B); // amber-500/30
  static const Color offlineText   = Color(0xFFFBBF24); // amber-400

  // ── Semantic: Error ───────────────────────────────────────────────────────
  static const Color error   = Color(0xFFF87171); // red-400
  static const Color errorBg = Color(0x33EF4444); // red-500/20

  // ── Quick-Action Icon Colours ─────────────────────────────────────────────
  static const Color sky      = Color(0xFF38BDF8); // sky-400
  static const Color skyBg    = Color(0x1A38BDF8); // sky-400/10
  static const Color purple   = Color(0xFFC084FC); // purple-400
  static const Color purpleBg = Color(0x1AC084FC); // purple-400/10
  static const Color orange   = Color(0xFFFB923C); // orange-400
  static const Color orangeBg = Color(0x1AFB923C); // orange-400/10

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color surfaceOverlay = Color(0xF2171717); // zinc-900/95 — toasts/overlays
  static const Color borderLight    = Color(0xFF3F3F46); // zinc-700 — skeleton pulse high
}

// ─────────────────────────────────────────────────────────────────────────────
// Spatial Scale
// Raw logical-pixel values matching Tailwind h-*/p-*/gap-* classes.
// Widgets use these as the base; ScreenUtil (.w .h .r) scales them in build().
// ─────────────────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double appBarHeight  = 56.0; // h-14
  static const double navHeight     = 64.0; // h-16
  static const double pagePadding   = 16.0; // px-4
  static const double sectionGap    = 20.0; // gap-5
  static const double cardGap       = 12.0; // gap-3
  static const double paddingCard   = 16.0; // p-4
  static const double paddingCardSm = 12.0; // p-3

  static const double radiusCard  = 12.0; // rounded-xl
  static const double radiusIcon  =  8.0; // rounded-lg
  static const double radiusToast = 16.0; // rounded-2xl
}

// ─────────────────────────────────────────────────────────────────────────────
// Typography
// Font family: system-native (SF Pro on iOS, Roboto on Android).
// No fontFamily override — Flutter defaults to the platform font automatically.
// Letter-spacing values are in logical pixels (CSS em converted @ base size).
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // text-[13px] font-bold tracking-tight
  static const TextStyle statusBar = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3, // -0.025em @ 13px
    color: AppColors.textPrimary,
  );

  // text-lg font-semibold  →  18px / 600
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // text-sm font-semibold  →  14px / 600
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // text-sm font-medium  →  14px / 500
  static const TextStyle bodyPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // text-xs  →  12px / 400
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // text-[10px] font-semibold  →  10px / 600
  static const TextStyle micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  // text-[11px] font-medium tracking-wide  →  11px / 500 / +0.3ls
  static const TextStyle greetingDate = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3, // 0.025em @ 11px
    color: AppColors.textTertiary,
  );

  // text-xl font-bold  →  20px / 700
  static const TextStyle greetingName = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // text-2xl font-bold leading-none  →  24px / 700 / height 1.0
  static const TextStyle countdown = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.accent,
  );

  // text-[10px] font-semibold tracking-wider  →  for "UP NEXT" uppercase label
  static const TextStyle eyebrow = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6, // 0.05em @ 10px — tracking-wider
    color: AppColors.textTertiary,
  );

  // text-[10px] font-semibold  →  nav tab labels, tag chips
  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppGlowTheme — ThemeExtension
//
// Provides surgical neon-yellow glow values and reusable decorations so
// any widget can call Theme.of(context).extension<AppGlowTheme>()!
// instead of hard-coding glow parameters inline.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class AppGlowTheme extends ThemeExtension<AppGlowTheme> {
  const AppGlowTheme({
    required this.accentGlowSm,
    required this.accentGlowMd,
    required this.accentGlowLg,
    required this.cardDecoration,
    required this.elevatedDecoration,
    required this.ambientTopGradient,
    required this.ambientTopGradientOffline,
  });

  /// Small glow — dots and unread indicators.
  /// Mirrors CSS: drop-shadow(0 0 6px rgba(253,224,71,0.50))
  final List<BoxShadow> accentGlowSm;

  /// Medium glow — active icons and highlighted elements.
  /// Mirrors CSS: drop-shadow(0 0 8px rgba(253,224,71,0.40))
  final List<BoxShadow> accentGlowMd;

  /// Large glow — primary CTA buttons.
  /// Mirrors CSS: drop-shadow(0 0 20px rgba(253,224,71,0.25))
  final List<BoxShadow> accentGlowLg;

  /// Standard card: zinc-900 surface + zinc-800 border + 12 px radius.
  final BoxDecoration cardDecoration;

  /// Elevated surface: zinc-900/80 + zinc-700/50 border + 12 px radius.
  /// Used for toasts, bottom sheets, and frosted overlays.
  final BoxDecoration elevatedDecoration;

  /// Faint yellow ambient gradient from the top of scrollable content.
  /// Online state variant (rgba(253,224,71,0.04) → transparent).
  final Gradient ambientTopGradient;

  /// Faint amber ambient gradient for the offline state scroll view.
  /// Offline variant (rgba(245,158,11,0.02) → transparent).
  final Gradient ambientTopGradientOffline;

  // ── Canonical dark-mode instance ─────────────────────────────────────────

  static const AppGlowTheme dark = AppGlowTheme(
    accentGlowSm: [
      BoxShadow(color: AppColors.accentGlow050, blurRadius: 6),
    ],
    accentGlowMd: [
      BoxShadow(color: AppColors.accentGlow040, blurRadius: 8),
    ],
    accentGlowLg: [
      BoxShadow(color: AppColors.accentGlow025, blurRadius: 20),
    ],
    cardDecoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusCard)),
      border: Border(
        top:    BorderSide(color: AppColors.border),
        right:  BorderSide(color: AppColors.border),
        bottom: BorderSide(color: AppColors.border),
        left:   BorderSide(color: AppColors.border),
      ),
    ),
    elevatedDecoration: BoxDecoration(
      color: Color(0xCC171717), // zinc-900/80
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusCard)),
      border: Border(
        top:    BorderSide(color: AppColors.borderElevated),
        right:  BorderSide(color: AppColors.borderElevated),
        bottom: BorderSide(color: AppColors.borderElevated),
        left:   BorderSide(color: AppColors.borderElevated),
      ),
    ),
    ambientTopGradient: RadialGradient(
      center: Alignment.topCenter,
      radius: 0.85,
      colors: [AppColors.accentAmbient, Colors.transparent],
    ),
    ambientTopGradientOffline: RadialGradient(
      center: Alignment.topCenter,
      radius: 0.85,
      colors: [AppColors.accentAmbientOffline, Colors.transparent],
    ),
  );

  // ── ThemeExtension API ────────────────────────────────────────────────────

  @override
  AppGlowTheme copyWith({
    List<BoxShadow>? accentGlowSm,
    List<BoxShadow>? accentGlowMd,
    List<BoxShadow>? accentGlowLg,
    BoxDecoration? cardDecoration,
    BoxDecoration? elevatedDecoration,
    Gradient? ambientTopGradient,
    Gradient? ambientTopGradientOffline,
  }) =>
      AppGlowTheme(
        accentGlowSm: accentGlowSm ?? this.accentGlowSm,
        accentGlowMd: accentGlowMd ?? this.accentGlowMd,
        accentGlowLg: accentGlowLg ?? this.accentGlowLg,
        cardDecoration: cardDecoration ?? this.cardDecoration,
        elevatedDecoration: elevatedDecoration ?? this.elevatedDecoration,
        ambientTopGradient: ambientTopGradient ?? this.ambientTopGradient,
        ambientTopGradientOffline:
            ambientTopGradientOffline ?? this.ambientTopGradientOffline,
      );

  @override
  AppGlowTheme lerp(ThemeExtension<AppGlowTheme>? other, double t) {
    if (other is! AppGlowTheme) return this;
    return AppGlowTheme(
      accentGlowSm: BoxShadow.lerpList(accentGlowSm, other.accentGlowSm, t) ??
          accentGlowSm,
      accentGlowMd: BoxShadow.lerpList(accentGlowMd, other.accentGlowMd, t) ??
          accentGlowMd,
      accentGlowLg: BoxShadow.lerpList(accentGlowLg, other.accentGlowLg, t) ??
          accentGlowLg,
      cardDecoration:
          BoxDecoration.lerp(cardDecoration, other.cardDecoration, t) ??
              cardDecoration,
      elevatedDecoration:
          BoxDecoration.lerp(elevatedDecoration, other.elevatedDecoration, t) ??
              elevatedDecoration,
      ambientTopGradient:
          Gradient.lerp(ambientTopGradient, other.ambientTopGradient, t) ??
              ambientTopGradient,
      ambientTopGradientOffline: Gradient.lerp(
              ambientTopGradientOffline, other.ambientTopGradientOffline, t) ??
          ambientTopGradientOffline,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.surface,
          secondary: AppColors.accent,
          onSecondary: AppColors.surface,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.textPrimary,
        ),
        // No fontFamily override — Flutter defaults to SF Pro (iOS) / Roboto (Android).
        textTheme: const TextTheme(
          titleLarge:  AppTextStyles.appBarTitle,
          titleMedium: AppTextStyles.sectionHeader,
          bodyMedium:  AppTextStyles.bodyPrimary,
          bodySmall:   AppTextStyles.bodySecondary,
          labelSmall:  AppTextStyles.micro,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textSecondary, size: 24),
          titleTextStyle: AppTextStyles.appBarTitle,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        dividerColor: AppColors.border,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        extensions: const [AppGlowTheme.dark],
      );
}
