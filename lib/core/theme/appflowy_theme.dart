import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flutter/material.dart';
import 'app_theme_config.dart';

/// MusclockBrandColors - Brand color constants
/// Now delegates to AppThemeConfig for centralized color management
class MusclockBrandColors {
  // 主要品牌色 (Muscle Clock Green) - delegated to AppThemeConfig
  static const Color primary = AppThemeConfig.brandPrimary;
  static const Color primaryLight = AppThemeConfig.brandPrimaryLight;
  static const Color primaryDark = AppThemeConfig.brandPrimaryDark;

  // 次要色
  static const Color accent = primary;
  static const Color accentLight = primaryLight;
}

/// Musclock主题构建器 - 结合AppFlowy和Musclock品牌色
class MusclockThemeBuilder implements AppFlowyThemeBuilder {
  @override
  AppFlowyThemeData light({String? fontFamily}) {
    final baseTheme = AppFlowyDefaultTheme().light(fontFamily: fontFamily);

    // 自定义填充色 - 添加Musclock品牌色
    final customFillColor = AppFlowyFillColorScheme(
      primary: baseTheme.fillColorScheme.primary,
      primaryHover: baseTheme.fillColorScheme.primaryHover,
      secondary: baseTheme.fillColorScheme.secondary,
      secondaryHover: baseTheme.fillColorScheme.secondaryHover,
      tertiary: baseTheme.fillColorScheme.tertiary,
      tertiaryHover: baseTheme.fillColorScheme.tertiaryHover,
      quaternary: baseTheme.fillColorScheme.quaternary,
      quaternaryHover: baseTheme.fillColorScheme.quaternaryHover,
      content: baseTheme.fillColorScheme.content,
      contentHover: baseTheme.fillColorScheme.contentHover,
      contentVisible: baseTheme.fillColorScheme.contentVisible,
      contentVisibleHover: baseTheme.fillColorScheme.contentVisibleHover,
      // 使用Musclock品牌色替代AppFlowy蓝色
      themeThick: MusclockBrandColors.primary,
      themeThickHover: MusclockBrandColors.primaryDark,
      themeSelect: MusclockBrandColors.primary.withOpacity(0.15),
      textSelect: MusclockBrandColors.primary.withOpacity(0.2),
      infoLight: baseTheme.fillColorScheme.infoLight,
      infoLightHover: baseTheme.fillColorScheme.infoLightHover,
      infoThick: baseTheme.fillColorScheme.infoThick,
      infoThickHover: baseTheme.fillColorScheme.infoThickHover,
      successLight: baseTheme.fillColorScheme.successLight,
      successLightHover: baseTheme.fillColorScheme.successLightHover,
      warningLight: baseTheme.fillColorScheme.warningLight,
      warningLightHover: baseTheme.fillColorScheme.warningLightHover,
      errorLight: baseTheme.fillColorScheme.errorLight,
      errorLightHover: baseTheme.fillColorScheme.errorLightHover,
      errorThick: baseTheme.fillColorScheme.errorThick,
      errorThickHover: baseTheme.fillColorScheme.errorThickHover,
      errorSelect: baseTheme.fillColorScheme.errorSelect,
      featuredLight: baseTheme.fillColorScheme.featuredLight,
      featuredLightHover: baseTheme.fillColorScheme.featuredLightHover,
      featuredThick: baseTheme.fillColorScheme.featuredThick,
      featuredThickHover: baseTheme.fillColorScheme.featuredThickHover,
    );

    // 自定义边框色
    final customBorderColor = AppFlowyBorderColorScheme(
      primary: baseTheme.borderColorScheme.primary,
      primaryHover: baseTheme.borderColorScheme.primaryHover,
      secondary: baseTheme.borderColorScheme.secondary,
      secondaryHover: baseTheme.borderColorScheme.secondaryHover,
      tertiary: baseTheme.borderColorScheme.tertiary,
      tertiaryHover: baseTheme.borderColorScheme.tertiaryHover,
      // 使用Musclock品牌色
      themeThick: MusclockBrandColors.primary,
      themeThickHover: MusclockBrandColors.primaryDark,
      infoThick: baseTheme.borderColorScheme.infoThick,
      infoThickHover: baseTheme.borderColorScheme.infoThickHover,
      successThick: baseTheme.borderColorScheme.successThick,
      successThickHover: baseTheme.borderColorScheme.successThickHover,
      warningThick: baseTheme.borderColorScheme.warningThick,
      warningThickHover: baseTheme.borderColorScheme.warningThickHover,
      errorThick: baseTheme.borderColorScheme.errorThick,
      errorThickHover: baseTheme.borderColorScheme.errorThickHover,
      featuredThick: baseTheme.borderColorScheme.featuredThick,
      featuredThickHover: baseTheme.borderColorScheme.featuredThickHover,
    );

    // 自定义文本色 - 添加动作颜色
    final customTextColor = AppFlowyTextColorScheme(
      primary: baseTheme.textColorScheme.primary,
      secondary: baseTheme.textColorScheme.secondary,
      tertiary: baseTheme.textColorScheme.tertiary,
      quaternary: baseTheme.textColorScheme.quaternary,
      onFill: baseTheme.textColorScheme.onFill,
      // 使用Musclock品牌色
      action: MusclockBrandColors.primary,
      actionHover: MusclockBrandColors.primaryDark,
      info: baseTheme.textColorScheme.info,
      infoHover: baseTheme.textColorScheme.infoHover,
      success: baseTheme.textColorScheme.success,
      successHover: baseTheme.textColorScheme.successHover,
      warning: baseTheme.textColorScheme.warning,
      warningHover: baseTheme.textColorScheme.warningHover,
      error: baseTheme.textColorScheme.error,
      errorHover: baseTheme.textColorScheme.errorHover,
      featured: baseTheme.textColorScheme.featured,
      featuredHover: baseTheme.textColorScheme.featuredHover,
    );

    // 自定义图标色
    final customIconColor = AppFlowyIconColorScheme(
      primary: baseTheme.iconColorScheme.primary,
      secondary: baseTheme.iconColorScheme.secondary,
      tertiary: baseTheme.iconColorScheme.tertiary,
      quaternary: baseTheme.iconColorScheme.quaternary,
      // 使用Musclock品牌色
      infoThick: MusclockBrandColors.primary,
      infoThickHover: MusclockBrandColors.primaryDark,
      successThick: baseTheme.iconColorScheme.successThick,
      successThickHover: baseTheme.iconColorScheme.successThickHover,
      warningThick: baseTheme.iconColorScheme.warningThick,
      warningThickHover: baseTheme.iconColorScheme.warningThickHover,
      errorThick: baseTheme.iconColorScheme.errorThick,
      errorThickHover: baseTheme.iconColorScheme.errorThickHover,
      featuredThick: baseTheme.iconColorScheme.featuredThick,
      featuredThickHover: baseTheme.iconColorScheme.featuredThickHover,
      onFill: baseTheme.iconColorScheme.onFill,
    );

    return AppFlowyThemeData(
      textStyle: baseTheme.textStyle,
      textColorScheme: customTextColor,
      iconColorScheme: customIconColor,
      borderColorScheme: customBorderColor,
      backgroundColorScheme: baseTheme.backgroundColorScheme,
      fillColorScheme: customFillColor,
      surfaceColorScheme: baseTheme.surfaceColorScheme,
      borderRadius: baseTheme.borderRadius,
      spacing: baseTheme.spacing,
      shadow: baseTheme.shadow,
      brandColorScheme: baseTheme.brandColorScheme,
      surfaceContainerColorScheme: baseTheme.surfaceContainerColorScheme,
      badgeColorScheme: baseTheme.badgeColorScheme,
      otherColorsColorScheme: baseTheme.otherColorsColorScheme,
    );
  }

  @override
  AppFlowyThemeData dark({String? fontFamily}) {
    final baseTheme = AppFlowyDefaultTheme().dark(fontFamily: fontFamily);

    // 自定义填充色 - 添加Musclock品牌色
    final customFillColor = AppFlowyFillColorScheme(
      primary: baseTheme.fillColorScheme.primary,
      primaryHover: baseTheme.fillColorScheme.primaryHover,
      secondary: baseTheme.fillColorScheme.secondary,
      secondaryHover: baseTheme.fillColorScheme.secondaryHover,
      tertiary: baseTheme.fillColorScheme.tertiary,
      tertiaryHover: baseTheme.fillColorScheme.tertiaryHover,
      quaternary: baseTheme.fillColorScheme.quaternary,
      quaternaryHover: baseTheme.fillColorScheme.quaternaryHover,
      content: baseTheme.fillColorScheme.content,
      contentHover: baseTheme.fillColorScheme.contentHover,
      contentVisible: baseTheme.fillColorScheme.contentVisible,
      contentVisibleHover: baseTheme.fillColorScheme.contentVisibleHover,
      // 使用Musclock品牌色
      themeThick: MusclockBrandColors.primary,
      themeThickHover: MusclockBrandColors.primaryLight,
      themeSelect: MusclockBrandColors.primary.withOpacity(0.2),
      textSelect: MusclockBrandColors.primary.withOpacity(0.25),
      infoLight: baseTheme.fillColorScheme.infoLight,
      infoLightHover: baseTheme.fillColorScheme.infoLightHover,
      infoThick: baseTheme.fillColorScheme.infoThick,
      infoThickHover: baseTheme.fillColorScheme.infoThickHover,
      successLight: baseTheme.fillColorScheme.successLight,
      successLightHover: baseTheme.fillColorScheme.successLightHover,
      warningLight: baseTheme.fillColorScheme.warningLight,
      warningLightHover: baseTheme.fillColorScheme.warningLightHover,
      errorLight: baseTheme.fillColorScheme.errorLight,
      errorLightHover: baseTheme.fillColorScheme.errorLightHover,
      errorThick: baseTheme.fillColorScheme.errorThick,
      errorThickHover: baseTheme.fillColorScheme.errorThickHover,
      errorSelect: baseTheme.fillColorScheme.errorSelect,
      featuredLight: baseTheme.fillColorScheme.featuredLight,
      featuredLightHover: baseTheme.fillColorScheme.featuredLightHover,
      featuredThick: baseTheme.fillColorScheme.featuredThick,
      featuredThickHover: baseTheme.fillColorScheme.featuredThickHover,
    );

    // 自定义边框色
    final customBorderColor = AppFlowyBorderColorScheme(
      primary: baseTheme.borderColorScheme.primary,
      primaryHover: baseTheme.borderColorScheme.primaryHover,
      secondary: baseTheme.borderColorScheme.secondary,
      secondaryHover: baseTheme.borderColorScheme.secondaryHover,
      tertiary: baseTheme.borderColorScheme.tertiary,
      tertiaryHover: baseTheme.borderColorScheme.tertiaryHover,
      themeThick: MusclockBrandColors.primary,
      themeThickHover: MusclockBrandColors.primaryLight,
      infoThick: baseTheme.borderColorScheme.infoThick,
      infoThickHover: baseTheme.borderColorScheme.infoThickHover,
      successThick: baseTheme.borderColorScheme.successThick,
      successThickHover: baseTheme.borderColorScheme.successThickHover,
      warningThick: baseTheme.borderColorScheme.warningThick,
      warningThickHover: baseTheme.borderColorScheme.warningThickHover,
      errorThick: baseTheme.borderColorScheme.errorThick,
      errorThickHover: baseTheme.borderColorScheme.errorThickHover,
      featuredThick: baseTheme.borderColorScheme.featuredThick,
      featuredThickHover: baseTheme.borderColorScheme.featuredThickHover,
    );

    // 自定义文本色
    final customTextColor = AppFlowyTextColorScheme(
      primary: baseTheme.textColorScheme.primary,
      secondary: baseTheme.textColorScheme.secondary,
      tertiary: baseTheme.textColorScheme.tertiary,
      quaternary: baseTheme.textColorScheme.quaternary,
      onFill: baseTheme.textColorScheme.onFill,
      action: MusclockBrandColors.primary,
      actionHover: MusclockBrandColors.primaryLight,
      info: baseTheme.textColorScheme.info,
      infoHover: baseTheme.textColorScheme.infoHover,
      success: baseTheme.textColorScheme.success,
      successHover: baseTheme.textColorScheme.successHover,
      warning: baseTheme.textColorScheme.warning,
      warningHover: baseTheme.textColorScheme.warningHover,
      error: baseTheme.textColorScheme.error,
      errorHover: baseTheme.textColorScheme.errorHover,
      featured: baseTheme.textColorScheme.featured,
      featuredHover: baseTheme.textColorScheme.featuredHover,
    );

    // 自定义图标色
    final customIconColor = AppFlowyIconColorScheme(
      primary: baseTheme.iconColorScheme.primary,
      secondary: baseTheme.iconColorScheme.secondary,
      tertiary: baseTheme.iconColorScheme.tertiary,
      quaternary: baseTheme.iconColorScheme.quaternary,
      infoThick: MusclockBrandColors.primary,
      infoThickHover: MusclockBrandColors.primaryLight,
      successThick: baseTheme.iconColorScheme.successThick,
      successThickHover: baseTheme.iconColorScheme.successThickHover,
      warningThick: baseTheme.iconColorScheme.warningThick,
      warningThickHover: baseTheme.iconColorScheme.warningThickHover,
      errorThick: baseTheme.iconColorScheme.errorThick,
      errorThickHover: baseTheme.iconColorScheme.errorThickHover,
      featuredThick: baseTheme.iconColorScheme.featuredThick,
      featuredThickHover: baseTheme.iconColorScheme.featuredThickHover,
      onFill: baseTheme.iconColorScheme.onFill,
    );

    return AppFlowyThemeData(
      textStyle: baseTheme.textStyle,
      textColorScheme: customTextColor,
      iconColorScheme: customIconColor,
      borderColorScheme: customBorderColor,
      backgroundColorScheme: baseTheme.backgroundColorScheme,
      fillColorScheme: customFillColor,
      surfaceColorScheme: baseTheme.surfaceColorScheme,
      borderRadius: baseTheme.borderRadius,
      spacing: baseTheme.spacing,
      shadow: baseTheme.shadow,
      brandColorScheme: baseTheme.brandColorScheme,
      surfaceContainerColorScheme: baseTheme.surfaceContainerColorScheme,
      badgeColorScheme: baseTheme.badgeColorScheme,
      otherColorsColorScheme: baseTheme.otherColorsColorScheme,
    );
  }
}

/// Musclock主题帮助类
class MusclockTheme {
  static AppFlowyThemeData get lightTheme => MusclockThemeBuilder().light();
  static AppFlowyThemeData get darkTheme => MusclockThemeBuilder().dark();

  static ThemeData get flutterTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MusclockBrandColors.primary,
        brightness: Brightness.light,
      ),
    );
  }
}
