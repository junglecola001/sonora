import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:prism_ui/prism_ui.dart';

import 'icons.dart';
import 'tokens.dart';

class SidebarEntry {
  const SidebarEntry({required this.label, required this.glyph});

  final String label;
  final Glyph glyph;
}

const sidebarNav = <SidebarEntry>[
  SidebarEntry(label: '歌曲', glyph: SonoraGlyphs.songs),
  SidebarEntry(label: '曲风', glyph: SonoraGlyphs.genre),
  SidebarEntry(label: '专辑', glyph: SonoraGlyphs.album),
  SidebarEntry(label: '艺术家', glyph: SonoraGlyphs.artist),
  SidebarEntry(label: '文件夹', glyph: SonoraGlyphs.folder),
  SidebarEntry(label: '音乐库', glyph: SonoraGlyphs.library),
  SidebarEntry(label: '设置', glyph: SonoraGlyphs.settings),
];

/// 固定宽度的资料库侧栏：主导航 + 歌单分组。
class SonoraSidebar extends StatelessWidget {
  const SonoraSidebar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Surface(
      color: scheme.surfaceContainerLowest,
      child: SizedBox(
        width: SonoraLayout.sidebarWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < sidebarNav.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _NavRow(
                    entry: sidebarNav[i],
                    selected: selected == i,
                    onTap: () => onSelected(i),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                child: Text(
                  '歌单',
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const _NavRow(
                entry: SidebarEntry(label: '我喜欢的音乐', glyph: SonoraGlyphs.heart),
                selected: false,
              ),
              const _NavRow(
                entry: SidebarEntry(label: '新建歌单', glyph: SonoraGlyphs.plus),
                selected: false,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  '本地 + 在线 · 单账号',
                  style: AppTextStyle.caption1
                      .of(context)
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.entry, required this.selected, this.onTap});

  final SidebarEntry entry;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final foreground = selected ? scheme.primary : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: entry.label,
      child: PressRegion(
        onTap: onTap,
        shape: AppShape.all(10),
        fill: selected ? scheme.primary.withValues(alpha: 0.18) : null,
        overlay: PressRegion.hoverOverlay,
        child: SizedBox(
          height: SonoraLayout.navItemHeight,
          child: Row(
            children: [
              const SizedBox(width: 10),
              GlyphIcon(entry.glyph, size: 18, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subheadline
                      .of(context, emphasized: selected)
                      .copyWith(color: foreground),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
