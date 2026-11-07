import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:prism_ui/prism_ui.dart';

import 'icons.dart';
import 'tokens.dart';

/// 底部常驻播放栏。M0 只有结构与占位状态，播放控制在内核接入后接线。
class SonoraPlayerBar extends StatelessWidget {
  const SonoraPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Surface(
      color: scheme.surfaceContainer,
      shape: Border(
        top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: SizedBox(
        height: SonoraLayout.playerBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const _CoverPlaceholder(),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('未在播放', style: AppTextStyle.subheadline.of(context)),
                  const SizedBox(height: 2),
                  Text(
                    '从资料库或在线搜索开始',
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              const _TransportControls(),
              const Spacer(),
              _ControlButton(glyph: SonoraGlyphs.queue, label: '播放队列'),
              const SizedBox(width: 4),
              _ControlButton(glyph: Glyphs.more, label: '更多'),
              const SizedBox(width: 16),
              Text(
                '输出 —',
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 16),
              _ControlButton(glyph: SonoraGlyphs.volume, label: '音量'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Surface(
      color: scheme.surfaceContainerHighest,
      shape: AppShape.all(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: GlyphIcon(
            SonoraGlyphs.songs,
            size: 22,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls();

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(glyph: SonoraGlyphs.shuffle, label: '随机播放'),
        const SizedBox(width: 4),
        _ControlButton(glyph: SonoraGlyphs.previous, label: '上一首'),
        const SizedBox(width: 8),
        Surface(
          color: scheme.primary,
          shape: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: GlyphIcon(
                SonoraGlyphs.play,
                size: 18,
                color: scheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _ControlButton(glyph: SonoraGlyphs.next, label: '下一首'),
        const SizedBox(width: 4),
        _ControlButton(glyph: SonoraGlyphs.repeat, label: '循环模式'),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.glyph, required this.label});

  final Glyph glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: PressRegion(
        shape: AppShape.all(8),
        overlay: PressRegion.hoverOverlay,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: GlyphIcon(glyph, size: 18, color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
