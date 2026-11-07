import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import '../../ui/player_bar.dart';
import '../../ui/sidebar.dart';
import '../../ui/title_bar.dart';
import '../../ui/tokens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Surface(
      color: scheme.surface,
      child: Column(
        children: [
          const SonoraTitleBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SonoraSidebar(
                  selected: _selected,
                  onSelected: (index) => setState(() => _selected = index),
                ),
                Expanded(child: _PageHost(index: _selected)),
              ],
            ),
          ),
          const SonoraPlayerBar(),
        ],
      ),
    );
  }
}

class _PageHost extends StatelessWidget {
  const _PageHost({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final (title, hint) = switch (index) {
      0 => ('歌曲', '本地曲库与在线搜索结果'),
      1 => ('曲风', '按曲风分类浏览本地曲目'),
      2 => ('专辑', '本地专辑与网易云专辑'),
      3 => ('艺术家', '本地艺术家与网易云歌手'),
      4 => ('文件夹', '按磁盘目录浏览'),
      5 => ('音乐库', '扫描根目录与增量索引'),
      _ => ('设置', '音频引擎、账号与界面'),
    };
    return _PlaceholderPage(title: title, hint: hint);
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Padding(
      padding: SonoraLayout.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.title1.of(context, emphasized: true)),
          const SizedBox(height: 6),
          Text(
            hint,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          Expanded(
            child: Center(
              child: Text(
                'M2 接入本地曲库与在线音源',
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(color: scheme.outline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
