import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// Salt Player 截图采样得到的强调色一族（见 docs/reference/README.md）。
const sonoraSeed = Color(0xFF4CC2FF);

ThemeData sonoraTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: sonoraSeed,
    brightness: brightness,
    style: ColorStyle.tinted,
  ),
  platform: TargetPlatform.windows,
  fontFamilyFallback: const ['Microsoft YaHei UI', 'Microsoft YaHei'],
);
